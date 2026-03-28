import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:athlos/athlos.dart';
import 'package:test/test.dart';

void main() {
  group('HttpServer routing', () {
    late HttpServer server;
    late io.HttpClient client;
    late int port;

    setUp(() async {
      port = await _findOpenPort();
      client = io.HttpClient();

      server = HttpServer(
        port: port,
        logger: NetworkLogger(output: NetworkLogOutput.console),
      );
    });

    tearDown(() async {
      await server.close();
      client.close(force: true);
    });

    test('routes GET request by URL path', () async {
      server.get('/health', (context) async {
        await context.json({'status': 'ok'});
      });

      await server.start();

      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/health'),
      );
      final response = await request.close();
      final body = await utf8.decodeStream(response);

      expect(response.statusCode, 200);
      expect(jsonDecode(body), {'status': 'ok'});
    });

    test('returns 405 for known path with unsupported method', () async {
      server.get('/profile', (context) async {
        await context.text('profile');
      });

      await server.start();

      final request = await client.postUrl(
        Uri.parse('http://127.0.0.1:$port/profile'),
      );
      final response = await request.close();
      final body = await utf8.decodeStream(response);

      expect(response.statusCode, 405);
      expect(jsonDecode(body), {'error': 'Method not allowed'});
    });

    test('returns 404 for unknown routes', () async {
      await server.start();

      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/unknown'),
      );
      final response = await request.close();
      final body = await utf8.decodeStream(response);

      expect(response.statusCode, 404);
      expect(jsonDecode(body), {'error': 'Not found'});
    });

    test('supports custom not-found handler', () async {
      server = HttpServer(
        port: port,
        logger: NetworkLogger(output: NetworkLogOutput.console),
        onRouteNotFound: (context) async {
          await context.json({'message': 'custom'}, statusCode: 418);
        },
      );

      await server.start();

      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/missing'),
      );
      final response = await request.close();
      final body = await utf8.decodeStream(response);

      expect(response.statusCode, 418);
      expect(jsonDecode(body), {'message': 'custom'});
    });

    test('reads binary request bodies', () async {
      server.post('/upload', (context) async {
        final bytes = await context.readBinary();
        await context.json({'length': bytes.length, 'sum': bytes.reduce((a, b) => a + b)});
      });

      await server.start();

      final request = await client.postUrl(
        Uri.parse('http://127.0.0.1:$port/upload'),
      );
      request.headers.contentType = io.ContentType.binary;
      request.add(Uint8List.fromList([1, 2, 3, 4]));

      final response = await request.close();
      final body = await utf8.decodeStream(response);

      expect(response.statusCode, 200);
      expect(jsonDecode(body), {'length': 4, 'sum': 10});
    });
  });
}

Future<int> _findOpenPort() async {
  final socket = await io.ServerSocket.bind(io.InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}
