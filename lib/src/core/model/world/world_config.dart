/// Represents the configuration for a world.
abstract class WorldConfig {

  int xBlockLimit;
  int yBlockLimit;
  int zBlockLimit;

  WorldConfig({
    required this.xBlockLimit,
    required this.yBlockLimit,
    required this.zBlockLimit,
  });

}