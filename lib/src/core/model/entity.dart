import 'package:athlos/src/core/model/transform/generic_transform.dart';

/// Represents an entity in the world, with a unique ID, position, and other properties.
abstract class Entity<TransformType extends Transform> {
  // The unique identifier for this entity, which can be used for database storage and retrieval.
  String id;

  // The ID of the world this entity belongs to
  String worldID;

  // The ID of the player that owns this entity, if any
  String playerID;

  // Area of interest radius for this entity, used for determining which other entities it can interact with
  double aoi;

  // The transform of this entity, including its position, direction, and orientation
  TransformType transform;

  // A list of valid action IDs that this entity can perform, which can be used for determining which actions are available to the player when interacting with this entity.
  List<String> validActionIDs = [];

  Entity({
    required this.id,
    required this.worldID,
    required this.playerID,
    required this.aoi,
    required this.transform
  });

}
