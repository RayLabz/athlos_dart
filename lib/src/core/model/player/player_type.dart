abstract class PlayerType {

  /// The unique identifier for the player.
  String id;

  /// The player type name.
  String name;

  /// The player type description.
  String? description;

  // A list of action IDs that the player type is allowed to perform, which can be used for determining which actions are available to the player.
  List<String> allowedActionIDs = [];

  PlayerType({
    required this.id,
    required this.name,
    this.description
  });

}