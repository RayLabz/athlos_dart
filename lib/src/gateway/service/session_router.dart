import '../model/backend_node.dart';
import '../model/gateway_route_info.dart';
import '../model/gateway_session.dart';

/// Stores session-to-backend routing mappings.
class GatewaySessionRouter {
  final Map<String, GatewaySession> _sessionsById = {};
  final Map<String, GatewaySession> _sessionsByClient = {};

  Iterable<GatewaySession> get sessions => _sessionsById.values;

  GatewaySession? findById(String sessionId) => _sessionsById[sessionId];

  GatewaySession? findByClient(String clientKey) =>
      _sessionsByClient[clientKey];

  void upsert(GatewaySession session) {
    final existing = _sessionsByClient[session.clientKey];
    if (existing != null) {
      _sessionsById.remove(existing.id);
    }

    _sessionsById[session.id] = session;
    _sessionsByClient[session.clientKey] = session;
  }

  GatewaySession? removeByClient(String clientKey) {
    final removed = _sessionsByClient.remove(clientKey);
    if (removed != null) {
      _sessionsById.remove(removed.id);
    }
    return removed;
  }

  GatewayRouteInfo? resolve(
    String sessionId,
    Map<String, BackendNode> backendsById,
  ) {
    final session = _sessionsById[sessionId];
    if (session == null) {
      return null;
    }

    final backend = backendsById[session.backendId];
    if (backend == null) {
      return null;
    }

    return GatewayRouteInfo(session: session, backend: backend);
  }
}
