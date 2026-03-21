import 'package:athlos/src/core/model/social/message.dart';

/// Represent a message sent directly from a player to another player.
abstract class DirectMessage extends Message {

  /// The ID of the player who receives the message.
  String receiverID;

  DirectMessage({
    required super.id,
    required super.senderID,
    required this.receiverID,
    required super.text,
    required super.sentOn
  });

}