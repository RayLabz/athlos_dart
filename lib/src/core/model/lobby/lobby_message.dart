/// Represents a lobby message.
abstract class LobbyMessage {

  /// The ID of the message.
  String id;

  /// The ID of the lobby that the message belongs to.
  String lobbyID;

  /// The ID of the player who sent the message.
  String senderID;

  /// The text content of the message.
  String text;

  /// The timestamp of when the message was sent.
  int sentOn = DateTime.now().millisecondsSinceEpoch;

  LobbyMessage({
    required this.id,
    required this.lobbyID,
    required this.senderID,
    required this.text,
    required this.sentOn
  });

}
