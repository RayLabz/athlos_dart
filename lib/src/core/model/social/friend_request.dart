import 'package:athlos/src/core/model/invitation.dart';

/// Represents a friend request.
abstract class FriendRequest extends Invitation {

  FriendRequest({
    required super.id,
    required super.senderID,
    required super.receiverID,
    required super.text,
    required super.sentOn,
  });

}
