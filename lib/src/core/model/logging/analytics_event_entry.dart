import 'package:athlos/src/core/model/logging/log_entry.dart';

/// Represents a log entry for an analytics event.
abstract class AnalyticsEventEntry extends LogEntry {

  AnalyticsEventEntry({
    required super.id,
    required super.name,
    required super.description,
    required super.occurredOnTimestamp,
  });

}