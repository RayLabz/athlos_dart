import 'package:athlos/src/core/model/invitation.dart';

/// Represents a lobby invitation.
abstract class LobbyInvitation extends Invitation {

  /// The ID of the world related to the invitation.
  String lobbyID;

  LobbyInvitation({
    required super.id,
    required super.senderID,
    required super.receiverID,
    required super.text,
    required super.sentOn,
    required super.acceptedOn,
    required this.lobbyID,
  });

}
