import '../core/net/network_logger.dart';
import 'model/backend_node.dart';
import 'model/gateway_route_info.dart';
import 'model/gateway_session.dart';
import 'model/gateway_transport.dart';
import 'service/backend_node_store.dart';
import 'service/ddos_guard.dart';
import 'service/gateway_authenticator.dart';
import 'service/gateway_matchmaker.dart';
import 'service/load_balancer.dart';
import 'service/session_router.dart';

/// Result returned by gateway operations.
class GatewayRelayResult {
  final bool ok;
  final String? error;
  final GatewayRouteInfo? route;
  final String? playerId;

  const GatewayRelayResult._({
    required this.ok,
    this.error,
    this.route,
    this.playerId,
  });

  factory GatewayRelayResult.success({
    GatewayRouteInfo? route,
    String? playerId,
  }) {
    return GatewayRelayResult._(ok: true, route: route, playerId: playerId);
  }

  factory GatewayRelayResult.failure(String message) {
    return GatewayRelayResult._(ok: false, error: message);
  }
}

/// Central orchestration layer for auth, matchmaking and session routing.
class GatewayRelay {
  final GatewayAuthenticator authenticator;
  final GatewayMatchmaker matchmaker;
  final GatewayLoadBalancer loadBalancer;
  final GatewayDdosGuard ddosGuard;
  final GatewaySessionRouter sessionRouter;
  final NetworkLogger logger;

  /// Optional file-backed store for backend node persistence.
  final BackendNodeStore? backendNodeStore;

  final Map<String, String> _playerByClient = {};
  final Map<String, BackendNode> _backendsById = {};

  int _nextSessionId = 1;
  bool _started = false;

  GatewayRelay({
    required this.authenticator,
    required this.matchmaker,
    required this.loadBalancer,
    required this.ddosGuard,
    Iterable<BackendNode> backends = const [],
    GatewaySessionRouter? sessionRouter,
    NetworkLogger? logger,
    this.backendNodeStore,
  }) : sessionRouter = sessionRouter ?? GatewaySessionRouter(),
       logger = logger ?? NetworkLogger() {
    for (final backend in backends) {
      _backendsById[backend.id] = backend;
    }
  }

  Iterable<BackendNode> get backends => _backendsById.values;

  /// Initialises the relay.
  ///
  /// If a [backendNodeStore] is configured this method attempts to load
  /// persisted backend nodes from the store file.
  ///
  /// * If the file exists its contents replace any nodes provided via the
  ///   constructor.
  /// * If the file does not exist, the constructor-provided nodes are written
  ///   to the store so future runs restore them.
  ///
  /// Calling [start] more than once is a no-op.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    final store = backendNodeStore;
    if (store == null) return;

    final loaded = await store.load();

    if (loaded.isNotEmpty) {
      _backendsById.clear();
      for (final node in loaded) {
        _backendsById[node.id] = node;
      }
      logger.log(
        'GatewayRelay',
        'Loaded ${loaded.length} backend node(s) from ${store.filePath}.',
      );
    } else {
      await store.save(_backendsById.values);
      logger.log(
        'GatewayRelay',
        'Created backend node store at ${store.filePath} '
            'with ${_backendsById.length} initial node(s).',
      );
    }
  }

  /// Registers a new backend node and persists the updated list.
  Future<void> addBackend(BackendNode backend) async {
    _backendsById[backend.id] = backend;
    logger.log('GatewayRelay', 'Backend node added: $backend');
    await _persist();
  }

  /// Removes a backend node by [id] and persists the updated list.
  ///
  /// Any in-flight sessions for the removed backend are left to expire
  /// naturally; new routing will no longer select it.
  Future<void> removeBackend(String id) async {
    final removed = _backendsById.remove(id);
    if (removed != null) {
      logger.log('GatewayRelay', 'Backend node removed: $id');
      await _persist();
    }
  }

  Future<GatewayRelayResult> authenticate({
    required String clientKey,
    required String token,
  }) async {
    if (!_allow(clientKey)) {
      return GatewayRelayResult.failure('Rate limit exceeded.');
    }

    final playerId = await authenticator.authenticate(token);
    if (playerId == null) {
      logger.log('GatewayRelay', 'Authentication failed for client=$clientKey');
      return GatewayRelayResult.failure('Authentication failed.');
    }

    _playerByClient[clientKey] = playerId;
    logger.log('GatewayRelay', 'Client authenticated: $clientKey -> $playerId');
    return GatewayRelayResult.success(playerId: playerId);
  }

  Future<GatewayRelayResult> createOrRefreshRoute({
    required String clientKey,
    required GatewayTransport transport,
  }) async {
    if (!_allow(clientKey)) {
      return GatewayRelayResult.failure('Rate limit exceeded.');
    }

    final playerId = _playerByClient[clientKey];
    if (playerId == null) {
      return GatewayRelayResult.failure('Client is not authenticated.');
    }

    final poolId = await matchmaker.resolvePool(playerId);
    final existing = sessionRouter.findByClient(clientKey);
    if (existing != null) {
      existing.lastSeen = DateTime.now();
      final existingRoute = sessionRouter.resolve(existing.id, _backendsById);
      if (existingRoute != null) {
        return GatewayRelayResult.success(
          route: existingRoute,
          playerId: playerId,
        );
      }
    }

    final backend = loadBalancer.selectNode(poolId, _backendsById.values);
    if (backend == null) {
      return GatewayRelayResult.failure('No backend server available.');
    }

    backend.activeSessions += 1;

    final session = GatewaySession(
      id: 'session-${_nextSessionId++}',
      clientKey: clientKey,
      playerId: playerId,
      backendId: backend.id,
      transport: transport,
    );

    sessionRouter.upsert(session);

    final route = GatewayRouteInfo(session: session, backend: backend);
    logger.log(
      'GatewayRelay',
      'Routed player=$playerId client=$clientKey to ${backend.id}:${backend.port}',
    );

    return GatewayRelayResult.success(route: route, playerId: playerId);
  }

  GatewayRelayResult routeInfo(String sessionId) {
    final route = sessionRouter.resolve(sessionId, _backendsById);
    if (route == null) {
      return GatewayRelayResult.failure('Session not found.');
    }

    route.session.lastSeen = DateTime.now();
    return GatewayRelayResult.success(
      route: route,
      playerId: route.session.playerId,
    );
  }

  void disconnect(String clientKey) {
    final removedSession = sessionRouter.removeByClient(clientKey);
    _playerByClient.remove(clientKey);

    if (removedSession != null) {
      final backend = _backendsById[removedSession.backendId];
      if (backend != null && backend.activeSessions > 0) {
        backend.activeSessions -= 1;
      }

      logger.log(
        'GatewayRelay',
        'Removed session ${removedSession.id} for client=$clientKey',
      );
    }
  }

  bool _allow(String clientKey) => ddosGuard.allowRequest(clientKey);

  Future<void> _persist() async {
    final store = backendNodeStore;
    if (store != null) {
      await store.save(_backendsById.values);
    }
  }
}
