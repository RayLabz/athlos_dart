/// Backend game server candidate for routing sessions.
class BackendNode {
  final String id;
  final String host;
  final int port;
  final int maxSessions;

  int activeSessions;

  BackendNode({
    required this.id,
    required this.host,
    required this.port,
    this.maxSessions = 500,
    this.activeSessions = 0,
  });

  bool get hasCapacity => activeSessions < maxSessions;

  factory BackendNode.fromJson(Map<String, dynamic> json) => BackendNode(
    id: json['id'] as String,
    host: json['host'] as String,
    port: json['port'] as int,
    maxSessions: json['maxSessions'] as int? ?? 500,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'host': host,
    'port': port,
    'maxSessions': maxSessions,
  };

  @override
  String toString() =>
      'BackendNode($id @ $host:$port, sessions=$activeSessions/$maxSessions)';
}
