import 'dart:io';

/// Determines where Athlos networking logs are written.
enum NetworkLogOutput { console, file, both }

/// Simple logger shared by networking clients and servers.
class NetworkLogger {
  final NetworkLogOutput output;
  final String filePath;

  NetworkLogger({
    this.output = NetworkLogOutput.both,
    this.filePath = 'athlos.log',
  });

  void log(String scope, String message) {
    final line = '[${DateTime.now().toIso8601String()}][$scope] $message';

    if (output == NetworkLogOutput.console || output == NetworkLogOutput.both) {
      print(line);
    }

    if (output == NetworkLogOutput.file || output == NetworkLogOutput.both) {
      final file = File(filePath);
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
    }
  }
}
