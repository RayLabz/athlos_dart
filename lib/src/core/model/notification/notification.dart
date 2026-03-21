/// A generic notification class.
abstract class Notification {

  /// The ID of the notification.
  String id;

  /// The name of the notification.
  String name;

  /// A brief description of the notification.
  String description;

  /// The timestamp when the notification was created.
  int createdOnTimestamp;

  /// Whether the notification has been read by the recipient.
  bool hasBeenRead;

  Notification({
    required this.id,
    required this.name,
    required this.description,
    required this.createdOnTimestamp,
    this.hasBeenRead = false,
  });

}