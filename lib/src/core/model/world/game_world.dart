import 'package:athlos/src/core/model/world/world_config.dart';
import 'package:athlos/src/core/model/world/world_status.dart';

/// A class representing a game world, which contains information about the world such as its name, description, and dimensions.
abstract class GameWorld<WorldConfigType extends WorldConfig> {
  // The unique identifier for the world.
  String id;

  // The ID of the user who created the world, which can be used for ownership and permissions management.
  String userID;

  // The name of the world, which can be displayed in the UI or used for logging.
  String name;

  // A brief description of the world, which can be displayed in the UI or used for tooltips.
  String? description;

  // The timestamp of when the world was created, which can be used for account management and analytics.
  int createdOn = DateTime.now().millisecondsSinceEpoch;

  // The configuration for the world, which contains information about the world such as its name, description, and dimensions.
  WorldConfigType worldConfig;

  // The status of the world.
  WorldStatus status;

  GameWorld({
    required this.id,
    required this.userID,
    required this.name,
    required this.worldConfig,
    this.status = WorldStatus.inactive,
    this.description,
  });
}
