import 'package:athlos/src/core/model/player/player_preferences.dart';
import 'package:athlos/src/core/model/player/player_type.dart';
import 'package:athlos/src/core/model/player/presence_status.dart';

import 'player_stats.dart';

/// A class representing a player in the game.
abstract class Player<PT extends PlayerType, PS extends PlayerStats, PP extends PlayerPreferences> {

  // The unique identifier for the player.
  String id;

  // The player's nickname
  String nickname;

  // The player's email address, which can be used for account management and communication.
  String emailAddress;

  // The ID of the team that the player belongs to, which can be used for team-based gameplay and matchmaking.
  String teamID;

  /// The IDs of the friends of the player.
  List<String> friendIDs = [];

  /// The IDs of players who have been blocked by this player.
  List<String> blockedPlayerIDs = [];

  // The timestamp of when the player last logged in.
  int? lastLogin;

  // The type of the player, determining its abilities and properties.
  PT type;

  // The stats of the player.
  PS? playerStats;

  // The preferences of the player.
  PP? playerPreferences;

  // The presence status of the player, determining their online status.
  PresenceStatus presenceStatus;

  // The timestamp of when the player was created, which can be used for account management and analytics.
  int createdOn = DateTime.now().millisecondsSinceEpoch;

  Player({
    required this.id,
    required this.nickname,
    required this.emailAddress,
    required this.teamID,
    required this.type,
    required this.createdOn,
    this.playerStats,
    this.playerPreferences,
    this.lastLogin,
    this.presenceStatus = PresenceStatus.offline
  });

}
