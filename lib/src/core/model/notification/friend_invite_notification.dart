import 'package:athlos/src/core/model/notification/notification.dart';

/// A friend invitation notification.
abstract class FriendInviteNotification extends Notification {

  /// The ID of the sender.
  String senderID;

  /// The ID of the receiver.
  String receiverID;

  FriendInviteNotification({
    required super.id,
    required super.name,
    required super.description,
    required super.createdOnTimestamp,
    super.hasBeenRead = false,
    required this.senderID,
    required this.receiverID,
  });

}