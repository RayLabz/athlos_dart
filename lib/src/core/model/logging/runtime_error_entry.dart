import 'package:athlos/src/core/model/logging/log_entry.dart';

/// Represents a runtime error log entry.
abstract class RuntimeErrorEntry extends LogEntry {

  RuntimeErrorEntry({
    required super.id,
    required super.description,
    required super.occurredOnTimestamp,
  }) : super(name: "⚠ Runtime Error");

}