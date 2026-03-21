import '../social/message.dart';

/// Represents a lobby message.
abstract class LobbyMessage extends Message {

  /// The ID of the lobby that the message belongs to.
  String lobbyID;

  LobbyMessage({
    required super.id,
    required this.lobbyID,
    required super.senderID,
    required super.text,
    required super.sentOn
  });

}
