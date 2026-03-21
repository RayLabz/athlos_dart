import 'package:athlos/src/core/model/position/grid_position.dart';

/// Represents a single spatial unit in the world/game.
abstract class SpatialUnit {

  String id;
  GridPosition position;

  SpatialUnit(this.position) : id = "${position.x}:${position.y}";

}