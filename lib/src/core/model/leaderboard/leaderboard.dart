import 'package:athlos/src/core/model/leaderboard/leaderboard_order.dart';
import 'package:athlos/src/core/model/leaderboard/leaderboard_player_scope.dart';
import 'package:athlos/src/core/model/leaderboard/leaderboard_world_scope.dart';
import 'package:athlos/src/core/model/player/player.dart';

/// Represents a leaderboard.
abstract class Leaderboard<PlayerType extends Player, PointType extends num> {

  // The name of the leaderboard.
  String name;

  // The ID of the world session associated with the leaderboard.
  String? worldSessionID;

  // A description of the leaderboard.
  String description;

  // The order in which players are ranked on the leaderboard.
  LeaderboardOrder order;

  // The player scope of the leaderboard (which set of players does it represent).
  LeaderboardPlayerScope playerScope;

  // The world scope of the leaderboard (which worlds does it represent).
  LeaderboardWorldScope worldScope;

  // A map of players to points representing the leaderboard.
  Map<PlayerType, PointType> playerRecords = {};

  // The timestamp of when the leaderboard was created.
  int createdOn = DateTime.now().millisecondsSinceEpoch;

  Leaderboard({
    required this.name,
    required this.description,
    required this.order,
    required this.playerScope,
    required this.worldScope,
    required this.playerRecords,
    required this.createdOn,
    this.worldSessionID,
  });
}
