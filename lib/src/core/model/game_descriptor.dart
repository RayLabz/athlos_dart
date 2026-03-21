/// A game descriptor, allowing games to track versions and the need for updates or reloading internal components from scratch.
abstract class GameDescriptor {

  /// The ID of the descriptor.
  String id;

  /// When the descriptor was published.
  int releaseTimestamp;

  /// Major version
  int majorVersion;

  /// Minor version
  int minorVersion;

  /// Build/patch version
  int buildVersion;

  GameDescriptor({
    required this.id,
    required this.releaseTimestamp,
    required this.majorVersion,
    required this.minorVersion,
    required this.buildVersion,
  });

}
