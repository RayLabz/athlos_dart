import 'package:athlos/src/core/model/player_type.dart';

import 'leaderboard/player_stats.dart';

/// A class representing a player in the game.
abstract class Player<PT extends PlayerType, PS extends PlayerStats> {

  // The unique identifier for the player.
  String id;

  // The player's nickname, which can be displayed in the UI or used for logging.
  String nickname;

  // The player's email address, which can be used for account management and communication.
  String emailAddress;

  // The ID of the team that the player belongs to, which can be used for team-based gameplay and matchmaking.
  String teamID;

  // The timestamp of when the player last logged in.
  int? lastLogin;

  // The type of the player, determining its abilities and properties.
  PT type;

  // The stats of the player.
  PS playerStats;

  // The timestamp of when the player was created, which can be used for account management and analytics.
  int createdOn = DateTime.now().millisecondsSinceEpoch;

  Player({
    required this.id,
    required this.nickname,
    required this.emailAddress,
    required this.teamID,
    required this.type,
    required this.playerStats,
    required this.createdOn,
    this.lastLogin,
  });

}
