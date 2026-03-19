/// Represents the stats of a player.
abstract class PlayerStats {

  /// The ID of the object.
  String id;

  /// The ID of the player.
  String playerID;

  /// The ID of the related world.
  String? worldID;

  PlayerStats({
    required this.id,
    required this.playerID,
    this.worldID
  });

}