import 'package:athlos/src/core/model/world/terrain_cell.dart';

import '../entity.dart';

/// Represents the current state of the game world.
/// Note: In many games, due to scalability requirements, the [GameState] may be partial rather than a full game state.
/// Whereas, in other, less demanding games, the [GameState] may be a full game state.
abstract class GameState<EntityType extends Entity, TerrainCellType extends TerrainCell> {

  // The ID of the world session associated with this game state.
  String worldSessionID;

  // A map of entity IDs to entities, representing the current state of the game world.
  Map<String, EntityType> entities = {};

  // A map of terrain cell hashes to terrain cells, representing the current state of the game world.
  Map<String, TerrainCellType> terrainCells = {};

  // The timestamp of when the game state was created or last updated, which can be used for synchronization and analytics.
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  GameState(this.worldSessionID);

}