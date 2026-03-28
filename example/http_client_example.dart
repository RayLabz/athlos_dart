import 'dart:io' as io;

import 'package:athlos/athlos.dart';

Future<void> main() async {
  final client = HttpClient(
    serverAddress: io.InternetAddress.loopbackIPv4,
    serverPort: 8080,
    logger: NetworkLogger(output: NetworkLogOutput.console),
    onMessage: (response) {
      print('Received ${response.statusCode} ${response.reasonPhrase}');
    },
  );

  await client.start();

  final response = await client.get('/health');
  print('Body: ${response.text}');

  await client.close();
}
