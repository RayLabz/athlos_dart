import 'dart:io';

import 'package:athlos/athlos.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkLogger output modes', () {
    test('file mode writes logs to file', () async {
      final tempDir = await Directory.systemTemp.createTemp('athlos_logger_');
      final logPath = '${tempDir.path}${Platform.pathSeparator}network.log';

      final logger = NetworkLogger(
        output: NetworkLogOutput.file,
        filePath: logPath,
      );

      logger.log('Test', 'file message');

      final file = File(logPath);
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('[Test] file message'));

      await tempDir.delete(recursive: true);
    });

    test('console mode does not create a log file by default', () async {
      final tempDir = await Directory.systemTemp.createTemp('athlos_logger_');
      final logPath = '${tempDir.path}${Platform.pathSeparator}network.log';

      final logger = NetworkLogger(
        output: NetworkLogOutput.console,
        filePath: logPath,
      );

      logger.log('Test', 'console only');

      final file = File(logPath);
      expect(file.existsSync(), isFalse);

      await tempDir.delete(recursive: true);
    });
  });
}
