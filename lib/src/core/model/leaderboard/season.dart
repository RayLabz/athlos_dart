/// Represents a season.
abstract class Season {

  /// The ID of the season.
  String id;

  /// The name of the season.
  String name;

  /// A description of the season.
  String? description;

  /// The timestamp of when the season started.
  int seasonStartTimestamp;

  /// The timestamp of when the season ends.
  int? seasonEndTimestamp;

  Season({
    required this.id,
    required this.name,
    this.description,
    required this.seasonStartTimestamp,
    this.seasonEndTimestamp,
  });

}
