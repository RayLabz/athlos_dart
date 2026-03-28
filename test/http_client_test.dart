import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:athlos/athlos.dart';
import 'package:test/test.dart';

void main() {
  group('HttpClient', () {
    late HttpServer server;
    late HttpClient client;
    late int port;
    late List<HttpClientResponseData> received;

    setUp(() async {
      port = await _findOpenPort();
      received = <HttpClientResponseData>[];

      server = HttpServer(
        port: port,
        logger: NetworkLogger(output: NetworkLogOutput.console),
      );

      server.get('/json', (context) async {
        await context.json({'status': 'ok'});
      });

      server.post('/echo', (context) async {
        final body = await utf8.decoder.bind(context.request).join();
        await context.text(body);
      });

      server.get('/binary', (context) async {
        await context.binary(Uint8List.fromList([1, 2, 3, 4]));
      });

      await server.start();

      client = HttpClient(
        serverAddress: io.InternetAddress.loopbackIPv4,
        serverPort: port,
        logger: NetworkLogger(output: NetworkLogOutput.console),
        onMessage: received.add,
      );

      await client.start();
    });

    tearDown(() async {
      await client.close();
      await server.close();
    });

    test('sends GET request and parses JSON response', () async {
      final response = await client.get('/json');

      expect(response.statusCode, 200);
      expect(response.json(), {'status': 'ok'});
      expect(received.length, 1);
    });

    test('sends POST request and receives echoed text', () async {
      final response = await client.post('/echo', body: 'ping');

      expect(response.statusCode, 200);
      expect(response.text, 'ping');
      expect(received.length, 1);
    });

    test('receives binary response', () async {
      final response = await client.get('/binary');

      expect(response.statusCode, 200);
      expect(response.body, Uint8List.fromList([1, 2, 3, 4]));
      expect(received.length, 1);
    });
  });
}

Future<int> _findOpenPort() async {
  final socket = await io.ServerSocket.bind(io.InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}
