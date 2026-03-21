/// Represents an in-game resource.
abstract class Resource {

  /// The ID of the resource.
  String id;

  /// The name of the resource.
  String name;

  /// A brief description of the resource.
  String description;

  Resource({
    required this.id,
    required this.name,
    required this.description
  });

}
