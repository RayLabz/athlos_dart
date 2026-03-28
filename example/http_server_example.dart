import 'package:athlos/athlos.dart';

Future<void> main() async {
  final server = HttpServer(
    port: 8080,
    logger: NetworkLogger(output: NetworkLogOutput.console),
  );

  server.get('/health', (context) async {
    await context.json({'status': 'ok'});
  });

  server.get('/hello', (context) async {
    final name = context.request.uri.queryParameters['name'] ?? 'world';
    await context.json({'message': 'Hello, $name!'});
  });

  await server.start();
}
