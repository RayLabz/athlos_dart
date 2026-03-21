/// Represents a player's progress or earning of an achievement.
abstract class PlayerAchievement {

  /// The ID of the player achievement.
  String id;

  /// The ID of the player associated with the achievement.
  String playerID;

  /// The ID of the achievement associated with the player achievement.
  String achievementID;

  /// The progress of the achievement.
  int progress = 0;

  /// The timestamp when the achievement was earned.
  int earnedOnTimestamp;

  PlayerAchievement({
    required this.id,
    required this.playerID,
    required this.achievementID,
    this.progress = 0,
    required this.earnedOnTimestamp
  });

}