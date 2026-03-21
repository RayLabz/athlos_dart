import 'package:athlos/src/core/model/transform/generic_transform.dart';

/// Represents an entity in the world, with a unique ID, position, and other properties.
abstract class Entity<TransformType extends Transform> {

  // The unique identifier for this entity.
  String id;

  // The ID of the world this entity belongs to
  String worldID;

  // The ID of the player that owns this entity, if any
  String? playerID;

  // Area of interest radius for this entity, used for determining which other entities it can interact with
  double aoi;

  /// The ID of the entity type.
  String entityTypeID;

  // The transform of this entity, including its position, direction, and orientation
  TransformType transform;

  Entity({
    required this.id,
    required this.worldID,
    this.playerID,
    required this.aoi,
    required this.transform,
    required this.entityTypeID,
  });

}
