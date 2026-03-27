import 'dart:convert';
import 'dart:io';

import '../model/backend_node.dart';

/// Persists backend node registrations to a local file.
///
/// The file is stored as a JSON array.  Only static configuration is
/// serialised (id, host, port, maxSessions).  The runtime [activeSessions]
/// counter is always reset to zero on load.
class BackendNodeStore {
  /// Path to the backing file.  Defaults to `backend-nodes.dat` in the
  /// current working directory.
  final String filePath;

  const BackendNodeStore({this.filePath = 'backend-nodes.dat'});

  /// Loads backend nodes from [filePath].
  ///
  /// Returns an empty list if the file does not exist or cannot be parsed.
  Future<List<BackendNode>> load() async {
    final file = File(filePath);

    if (!await file.exists()) {
      return const [];
    }

    try {
      final content = await file.readAsString();
      final dynamic decoded = jsonDecode(content);

      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(BackendNode.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Writes [nodes] to [filePath], creating parent directories as needed.
  Future<void> save(Iterable<BackendNode> nodes) async {
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(nodes.map((n) => n.toJson()).toList()),
      flush: true,
    );
  }
}
