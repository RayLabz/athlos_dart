/// Represents a generic message.
abstract class Message {

  /// The ID of the message.
  String id;

  /// The ID of the player who sent the message.
  String senderID;

  /// The text content of the message.
  String text;

  /// The timestamp of when the message was sent.
  int sentOn = DateTime.now().millisecondsSinceEpoch;

  Message({
    required this.id,
    required this.senderID,
    required this.text,
    required this.sentOn,
  });

}