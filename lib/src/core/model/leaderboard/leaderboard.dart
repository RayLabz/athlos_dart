import 'package:athlos/src/core/model/leaderboard/leaderboard_order.dart';
import 'package:athlos/src/core/model/leaderboard/leaderboard_scope.dart';
import 'package:athlos/src/core/model/player.dart';

/// Represents a leaderboard.
abstract class Leaderboard<PlayerType extends Player, PointType extends num> {
  // The name of the leaderboard.
  String name;

  // The ID of the world session associated with the leaderboard.
  String worldSessionID;

  // A description of the leaderboard.
  String description;

  // The order in which players are ranked on the leaderboard.
  LeaderboardOrder order;

  // The scope of the leaderboard.
  LeaderboardScope scope;

  // A map of players to points representing the leaderboard.
  Map<PlayerType, PointType> players = {};

  // The timestamp of when the leaderboard was created.
  int createdOn = DateTime.now().millisecondsSinceEpoch;

  Leaderboard({
    required this.name,
    required this.worldSessionID,
    required this.description,
    required this.order,
    required this.scope,
    required this.players,
    required this.createdOn,
  });
}
