abstract class LogEntry {

  /// The ID of the log entry.
  String id;

  /// The name of the log entry.
  String name;

  /// A brief description of the log entry.
  String? description;

  /// The time at which the entry was recorded.
  int occurredOnTimestamp;

  LogEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.occurredOnTimestamp,
  });

}