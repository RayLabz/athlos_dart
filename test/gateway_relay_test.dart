import 'dart:io';

import 'package:athlos/athlos.dart';
import 'package:test/test.dart';

void main() {
  group('GatewayRelay', () {
    late BackendNode nodeA;
    late BackendNode nodeB;
    late GatewayRelay relay;

    setUp(() {
      nodeA = BackendNode(
        id: 'node-a',
        host: '10.0.0.1',
        port: 9001,
        maxSessions: 2,
      );
      nodeB = BackendNode(
        id: 'node-b',
        host: '10.0.0.2',
        port: 9002,
        maxSessions: 2,
      );

      relay = GatewayRelay(
        authenticator: InMemoryGatewayAuthenticator({
          'token-a': 'player-a',
          'token-b': 'player-b',
          'token-c': 'player-c',
        }),
        matchmaker: const DefaultGatewayMatchmaker(),
        loadBalancer: const LeastConnectionsLoadBalancer(),
        ddosGuard: SlidingWindowDdosGuard(
          maxRequests: 100,
          window: const Duration(seconds: 5),
        ),
        backends: [nodeA, nodeB],
      );
    });

    test('rejects unauthenticated routing requests', () async {
      final result = await relay.createOrRefreshRoute(
        clientKey: 'c1',
        transport: GatewayTransport.tcp,
      );

      expect(result.ok, isFalse);
      expect(result.error, contains('not authenticated'));
    });

    test('authenticates and routes to backend', () async {
      final auth = await relay.authenticate(clientKey: 'c1', token: 'token-a');
      final routed = await relay.createOrRefreshRoute(
        clientKey: 'c1',
        transport: GatewayTransport.tcp,
      );

      expect(auth.ok, isTrue);
      expect(routed.ok, isTrue);
      expect(routed.route, isNotNull);
      expect(routed.route!.backend.id, isNotEmpty);
      expect(routed.route!.session.playerId, 'player-a');
    });

    test('least-connections balancing picks less loaded node', () async {
      await relay.authenticate(clientKey: 'c1', token: 'token-a');
      final firstRoute = await relay.createOrRefreshRoute(
        clientKey: 'c1',
        transport: GatewayTransport.tcp,
      );

      await relay.authenticate(clientKey: 'c2', token: 'token-b');
      final secondRoute = await relay.createOrRefreshRoute(
        clientKey: 'c2',
        transport: GatewayTransport.tcp,
      );

      expect(firstRoute.ok, isTrue);
      expect(secondRoute.ok, isTrue);
      expect(
        firstRoute.route!.backend.id != secondRoute.route!.backend.id,
        isTrue,
      );
    });

    test('ddos guard blocks excessive requests', () async {
      final limitedRelay = GatewayRelay(
        authenticator: InMemoryGatewayAuthenticator({'token': 'player'}),
        matchmaker: const DefaultGatewayMatchmaker(),
        loadBalancer: const LeastConnectionsLoadBalancer(),
        ddosGuard: SlidingWindowDdosGuard(
          maxRequests: 1,
          window: const Duration(seconds: 10),
        ),
        backends: [BackendNode(id: 'n', host: '127.0.0.1', port: 9000)],
      );

      final first = await limitedRelay.authenticate(
        clientKey: 'abuse',
        token: 'token',
      );
      final second = await limitedRelay.authenticate(
        clientKey: 'abuse',
        token: 'token',
      );

      expect(first.ok, isTrue);
      expect(second.ok, isFalse);
      expect(second.error, contains('Rate limit'));
    });

    test('disconnect decreases backend active sessions', () async {
      await relay.authenticate(clientKey: 'c1', token: 'token-a');
      final routed = await relay.createOrRefreshRoute(
        clientKey: 'c1',
        transport: GatewayTransport.udp,
      );

      expect(routed.ok, isTrue);
      final backendId = routed.route!.backend.id;
      final before = relay.backends
          .firstWhere((n) => n.id == backendId)
          .activeSessions;
      relay.disconnect('c1');
      final after = relay.backends
          .firstWhere((n) => n.id == backendId)
          .activeSessions;

      expect(before, 1);
      expect(after, 0);
    });
  });

  group('BackendNodeStore', () {
    late Directory tempDir;
    late String storePath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('athlos_store_');
      storePath = '${tempDir.path}${Platform.pathSeparator}backend-nodes.dat';
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('returns empty list when file does not exist', () async {
      final store = BackendNodeStore(filePath: storePath);
      final nodes = await store.load();
      expect(nodes, isEmpty);
    });

    test('saves and reloads backend nodes', () async {
      final store = BackendNodeStore(filePath: storePath);

      await store.save([
        BackendNode(id: 'n1', host: '10.0.0.1', port: 9001, maxSessions: 10),
        BackendNode(id: 'n2', host: '10.0.0.2', port: 9002),
      ]);

      final loaded = await store.load();

      expect(loaded.length, 2);
      expect(loaded[0].id, 'n1');
      expect(loaded[0].host, '10.0.0.1');
      expect(loaded[0].port, 9001);
      expect(loaded[0].maxSessions, 10);
      expect(loaded[0].activeSessions, 0); // runtime state reset on load
      expect(loaded[1].id, 'n2');
    });

    test('activeSessions is always reset to zero on load', () async {
      final store = BackendNodeStore(filePath: storePath);
      final node = BackendNode(id: 'n1', host: '127.0.0.1', port: 8000)
        ..activeSessions = 42;

      await store.save([node]);
      final loaded = await store.load();

      expect(loaded.first.activeSessions, 0);
    });
  });

  group('GatewayRelay dynamic backend management', () {
    late Directory tempDir;
    late String storePath;
    late GatewayRelay relay;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('athlos_relay_');
      storePath = '${tempDir.path}${Platform.pathSeparator}backend-nodes.dat';

      relay = GatewayRelay(
        authenticator: InMemoryGatewayAuthenticator({'t': 'p'}),
        matchmaker: const DefaultGatewayMatchmaker(),
        loadBalancer: const LeastConnectionsLoadBalancer(),
        ddosGuard: SlidingWindowDdosGuard(maxRequests: 100),
        backendNodeStore: BackendNodeStore(filePath: storePath),
      );

      await relay.start();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('starts with no backends when store file is absent', () {
      expect(relay.backends, isEmpty);
    });

    test('addBackend registers node and saves to file', () async {
      await relay.addBackend(
        BackendNode(id: 'g1', host: '127.0.0.1', port: 9001),
      );

      expect(relay.backends.map((n) => n.id), contains('g1'));

      final reloaded = await BackendNodeStore(filePath: storePath).load();
      expect(reloaded.any((n) => n.id == 'g1'), isTrue);
    });

    test('removeBackend deregisters node and saves to file', () async {
      await relay.addBackend(
        BackendNode(id: 'g1', host: '127.0.0.1', port: 9001),
      );
      await relay.addBackend(
        BackendNode(id: 'g2', host: '127.0.0.1', port: 9002),
      );

      await relay.removeBackend('g1');

      expect(relay.backends.map((n) => n.id), isNot(contains('g1')));
      expect(relay.backends.map((n) => n.id), contains('g2'));

      final reloaded = await BackendNodeStore(filePath: storePath).load();
      expect(reloaded.any((n) => n.id == 'g1'), isFalse);
      expect(reloaded.any((n) => n.id == 'g2'), isTrue);
    });

    test('start loads persisted backends on second relay instance', () async {
      await relay.addBackend(
        BackendNode(id: 'g1', host: '127.0.0.1', port: 9001),
      );

      // New relay instance, same store file – simulates process restart.
      final relay2 = GatewayRelay(
        authenticator: InMemoryGatewayAuthenticator({}),
        matchmaker: const DefaultGatewayMatchmaker(),
        loadBalancer: const LeastConnectionsLoadBalancer(),
        ddosGuard: SlidingWindowDdosGuard(maxRequests: 100),
        backendNodeStore: BackendNodeStore(filePath: storePath),
      );

      await relay2.start();

      expect(relay2.backends.map((n) => n.id), contains('g1'));
    });

    test(
      'seed backends are written to new store file on first start',
      () async {
        final seededPath = '${tempDir.path}${Platform.pathSeparator}seeded.dat';

        final seededRelay = GatewayRelay(
          authenticator: InMemoryGatewayAuthenticator({}),
          matchmaker: const DefaultGatewayMatchmaker(),
          loadBalancer: const LeastConnectionsLoadBalancer(),
          ddosGuard: SlidingWindowDdosGuard(maxRequests: 100),
          backends: [BackendNode(id: 'seed1', host: '127.0.0.1', port: 9999)],
          backendNodeStore: BackendNodeStore(filePath: seededPath),
        );

        await seededRelay.start();

        expect(seededRelay.backends.map((n) => n.id), contains('seed1'));

        final written = await BackendNodeStore(filePath: seededPath).load();
        expect(written.any((n) => n.id == 'seed1'), isTrue);
      },
    );
  });
}
