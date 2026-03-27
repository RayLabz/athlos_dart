import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:athlos/athlos.dart';
import 'package:test/test.dart';

void main() {
  group('TCP networking', () {
    test(
      'server decodes framed client messages and client receives response',
      () async {
        final port = await _findOpenPort();
        final receivedMessages = <String>[];
        final serverMessagesCompleter = Completer<List<String>>();
        final clientResponseCompleter = Completer<String>();

        late final TcpServer server;
        server = TcpServer(
          port: port,
          onMessage: (Uint8List message, TcpClientInfo client) {
            final decoded = utf8.decode(message);
            receivedMessages.add(decoded);

            if (decoded == 'ping') {
              server.send(_encode('pong'), client);
            }

            if (receivedMessages.length == 2 &&
                !serverMessagesCompleter.isCompleted) {
              serverMessagesCompleter.complete(
                List<String>.from(receivedMessages),
              );
            }
          },
        );

        await server.start();

        final client = TcpClient(
          serverAddress: InternetAddress.loopbackIPv4,
          serverPort: port,
          onMessage: (Uint8List message) {
            if (!clientResponseCompleter.isCompleted) {
              clientResponseCompleter.complete(utf8.decode(message));
            }
          },
        );

        await client.start();
        await _waitUntil(() => server.clients.length == 1);

        client.send(_encode('first'));
        client.send(_encode('ping'));

        expect(await serverMessagesCompleter.future, ['first', 'ping']);
        expect(await clientResponseCompleter.future, 'pong');

        await client.close();
        await _waitUntil(() => server.clients.isEmpty);
        await server.close();
      },
    );

    test('server broadcast reaches all connected TCP clients', () async {
      final port = await _findOpenPort();
      final firstClientCompleter = Completer<String>();
      final secondClientCompleter = Completer<String>();

      final server = TcpServer(port: port, onMessage: (_, __) {});

      await server.start();

      final firstClient = TcpClient(
        serverAddress: InternetAddress.loopbackIPv4,
        serverPort: port,
        onMessage: (Uint8List message) {
          if (!firstClientCompleter.isCompleted) {
            firstClientCompleter.complete(utf8.decode(message));
          }
        },
      );

      final secondClient = TcpClient(
        serverAddress: InternetAddress.loopbackIPv4,
        serverPort: port,
        onMessage: (Uint8List message) {
          if (!secondClientCompleter.isCompleted) {
            secondClientCompleter.complete(utf8.decode(message));
          }
        },
      );

      await firstClient.start();
      await secondClient.start();
      await _waitUntil(() => server.clients.length == 2);

      server.broadcast(_encode('hello everyone'));

      expect(await firstClientCompleter.future, 'hello everyone');
      expect(await secondClientCompleter.future, 'hello everyone');

      await firstClient.close();
      await secondClient.close();
      await _waitUntil(() => server.clients.isEmpty);
      await server.close();
    });

    test('server triggers client lifecycle callbacks', () async {
      final port = await _findOpenPort();
      final connectedCompleter = Completer<TcpClientInfo>();
      final disconnectedCompleter = Completer<TcpClientInfo>();

      final server = TcpServer(
        port: port,
        onMessage: (_, __) {},
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

      final client = TcpClient(
        serverAddress: InternetAddress.loopbackIPv4,
        serverPort: port,
        onMessage: (_) {},
      );

      await client.start();

      final connectedClient = await connectedCompleter.future;

      await client.close();

      final disconnectedClient = await disconnectedCompleter.future;

      expect(disconnectedClient.key, connectedClient.key);

      await server.close();
    });
  });
}

Uint8List _encode(String value) => Uint8List.fromList(utf8.encode(value));

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
