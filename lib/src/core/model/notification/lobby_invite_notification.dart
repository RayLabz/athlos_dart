import 'package:athlos/src/core/model/notification/notification.dart';

/// A notification for a lobby invite.
abstract class LobbyInviteNotification extends Notification {

  /// The ID of the lobby being invited to
  String lobbyID;

  /// The ID of the sender.
  String senderID;

  /// The ID of the receiver.
  String receiverID;

  LobbyInviteNotification({
    required super.id,
    required super.name,
    required super.description,
    required super.createdOnTimestamp,
    super.hasBeenRead = false,
    required this.lobbyID,
    required this.senderID,
    required this.receiverID,
  });

}