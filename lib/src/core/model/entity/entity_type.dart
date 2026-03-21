/// Represents a type of entity in the game.
abstract class EntityType {

  /// The ID of the entity type.
  String id;

  /// The name of the entity type.
  String name;

  // A list of valid action IDs that this entity can perform, which can be used for determining
  // which actions are available to the player when using this type of entity.
  List<String> validActionIDs;

  EntityType({
    required this.id,
    required this.name,
    required this.validActionIDs,
  });

}