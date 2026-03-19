import '../../../../athlos.dart';

/// Represents a scheduled event in the game.
abstract class ScheduledEvent<PositionType extends WorldPosition> {

  /// The unique identifier for the event.
  String id;

  /// The time at which the event will be executed.
  int happensAtTimestamp;

  /// The ID of the world that the event belongs to.
  String worldID;

  /// A list of player IDs that need to be notified of the event.
  List<String> notifiedPlayersIDs = [];

  /// The position at which the event originates.
  PositionType? originPosition;

  /// The Area of Effect of the event (an area within which the event can affect/update other entities).
  double? aoe;

  ScheduledEvent({
    required this.id,
    required this.happensAtTimestamp,
    required this.worldID,
    this.originPosition,
    this.aoe,
    this.notifiedPlayersIDs = const [],
  });

}