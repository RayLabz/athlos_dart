import '../../../../athlos.dart';

/// Represents a record of an event in the game for logging purposes.
abstract class EventRecord<PositionType extends WorldPosition> {

  /// The unique identifier for the event.
  String id;

  /// A brief description of the event.
  String description;

  /// The time at which the event happened.
  int occurredOnTimestamp;

  /// The ID of the world that the event belongs to.
  String worldID;

  /// The position at which the event originated.
  PositionType? originPosition;

  EventRecord({
    required this.id,
    required this.description,
    required this.occurredOnTimestamp,
    required this.worldID,
    this.originPosition
  });

}