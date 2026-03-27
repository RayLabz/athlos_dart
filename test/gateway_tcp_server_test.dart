import 'dart:io';

import 'package:athlos/athlos.dart';
import 'package:test/test.dart';

void main() {
  test('GatewayTcpServer authenticates and returns routing info', () async {
    final port = await _findOpenPort();

    final relay = GatewayRelay(
      authenticator: InMemoryGatewayAuthenticator({'token-1': 'player-1'}),
      matchmaker: const DefaultGatewayMatchmaker(),
      loadBalancer: const LeastConnectionsLoadBalancer(),
      ddosGuard: SlidingWindowDdosGuard(
        maxRequests: 20,
        window: const Duration(seconds: 3),
      ),
      backends: [BackendNode(id: 'game-1', host: '127.0.0.1', port: 10001)],
    );

    final gateway = GatewayTcpServer(port: port, relay: relay);
    await gateway.start();

    final responsePackets = <GatewayPacket>[];
    final client = TcpClient(
      serverAddress: InternetAddress.loopbackIPv4,
      serverPort: port,
      onMessage: (bytes) {
        final packet = GatewayPacket.tryParse(bytes);
        if (packet != null) {
          responsePackets.add(packet);
        }
      },
    );

    await client.start();

    client.send(
      GatewayPacket(
        opcode: GatewayOpcode.authenticate,
        data: {'token': 'token-1'},
      ).toBytes(),
    );

    client.send(
      const GatewayPacket(opcode: GatewayOpcode.matchmakingRequest).toBytes(),
    );

    await _waitUntil(() => responsePackets.length >= 2);

    expect(responsePackets[0].opcode, GatewayOpcode.authenticated);
    expect(responsePackets[1].opcode, GatewayOpcode.routed);
    expect((responsePackets[1].data['backend'] as Map)['id'], 'game-1');

    await client.close();
    await gateway.close();
  });
}

Future<int> _findOpenPort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

Future<void> _waitUntil(
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 3),
  Duration step = const Duration(milliseconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(step);
  }

  if (!predicate()) {
    fail('Condition not met within $timeout.');
  }
}
