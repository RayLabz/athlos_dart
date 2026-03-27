import 'dart:async';
import 'dart:io';

import 'package:athlos/athlos.dart';
import 'package:test/test.dart';

void main() {
  group('Udp keepalive lifecycle', () {
    test('client keepalive handshake keeps connection alive', () async {
      final port = await _findOpenPort();

      final server = UdpServer(
        port: port,
        onMessage: (_, __, ___) {},
        tickRate: const Duration(milliseconds: 20),
        clientTimeout: const Duration(milliseconds: 180),
      );

      await server.start();

      final client = UdpClient(
        serverAddress: InternetAddress.loopbackIPv4,
        serverPort: port,
        onMessage: (_) {},
        handshakeInterval: const Duration(milliseconds: 50),
      );

      await client.start();

      await Future<void>.delayed(const Duration(milliseconds: 260));
      expect(server.clients.length, 1);

      client.close();
      server.close();
    });

    test('server removes client when handshake is stale', () async {
      final port = await _findOpenPort();

      final server = UdpServer(
        port: port,
        onMessage: (_, __, ___) {},
        tickRate: const Duration(milliseconds: 20),
        clientTimeout: const Duration(milliseconds: 120),
      );

      await server.start();

      final rawClient = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );

      rawClient.send(
        UdpControlMessage.handshake(),
        InternetAddress.loopbackIPv4,
        port,
      );

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(server.clients.length, 1);

      await Future<void>.delayed(const Duration(milliseconds: 220));
      expect(server.clients.length, 0);

      rawClient.close();
      server.close();
    });

    test('server removes client immediately on disconnect message', () async {
      final port = await _findOpenPort();

      final server = UdpServer(
        port: port,
        onMessage: (_, __, ___) {},
        tickRate: const Duration(milliseconds: 20),
        clientTimeout: const Duration(milliseconds: 300),
      );

      await server.start();

      final rawClient = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );

      rawClient.send(
        UdpControlMessage.handshake(),
        InternetAddress.loopbackIPv4,
        port,
      );

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(server.clients.length, 1);

      rawClient.send(
        UdpControlMessage.disconnect(),
        InternetAddress.loopbackIPv4,
        port,
      );

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(server.clients.length, 0);

      rawClient.close();
      server.close();
    });

    test('server triggers client lifecycle callbacks', () async {
      final port = await _findOpenPort();
      final connectedCompleter = Completer<UdpClientInfo>();
      final disconnectedCompleter = Completer<UdpClientInfo>();

      final server = UdpServer(
        port: port,
        onMessage: (_, __, ___) {},
        tickRate: const Duration(milliseconds: 20),
        clientTimeout: const Duration(seconds: 3),
        onClientConnected: (client) {
          if (!connectedCompleter.isCompleted) {
            connectedCompleter.complete(client);
          }
        },
        onClientDisconnected: (client) {
          if (!disconnectedCompleter.isCompleted) {
            disconnectedCompleter.complete(client);
          }
        },
      );

      await server.start();

      final rawClient = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );

      rawClient.send(
        UdpControlMessage.handshake(),
        InternetAddress.loopbackIPv4,
        port,
      );

      final connectedClient = await connectedCompleter.future;

      rawClient.send(
        UdpControlMessage.disconnect(),
        InternetAddress.loopbackIPv4,
        port,
      );

      final disconnectedClient = await disconnectedCompleter.future;

      expect(disconnectedClient.key, connectedClient.key);

      rawClient.close();
      server.close();
    });
  });
}

Future<int> _findOpenPort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}
