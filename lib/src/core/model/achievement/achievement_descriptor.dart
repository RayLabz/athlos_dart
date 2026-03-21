/// Describes an in-game achievement.
abstract class AchievementDescriptor {

  /// The ID of the achievement.
  String id;

  /// The name of the achievement.
  String name;

  /// A description of the achievement.
  String description;

  AchievementDescriptor({
    required this.id,
    required this.name,
    required this.description
  });

}
