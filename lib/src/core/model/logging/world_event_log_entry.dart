import 'package:athlos/src/core/model/logging/log_entry.dart';

import '../../../../athlos.dart';

/// Represents a record of an event in the game for logging purposes.
abstract class WorldEventLogEntry<PositionType extends WorldPosition>
    extends LogEntry {

  /// The ID of the world that the event belongs to.
  String worldID;

  /// The position at which the event originated.
  PositionType? originPosition;

  /// The ID of the players who were related to the event.
  List<String>? relatedPlayerIDs;

  WorldEventLogEntry({
    required super.id,
    required super.name,
    required super.description,
    required super.occurredOnTimestamp,
    required this.worldID,
    required this.originPosition,
    required this.relatedPlayerIDs,
  });

}
