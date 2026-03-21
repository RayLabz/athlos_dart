/// Represents a generic invitation.
abstract class Invitation {

  /// The ID of the invitation.
  String id;

  /// The ID of the player sending the invite.
  String senderID;

  /// The ID of the player being invited.
  String receiverID;

  /// An optional text set by the invitee.
  String? text;

  /// The timestamp of when the invite was created.
  int sentOn = DateTime.now().millisecondsSinceEpoch;

  /// The timestamp of when the invite was accepted.
  int? acceptedOn;

  Invitation({
    required this.id,
    required this.senderID,
    required this.receiverID,
    required this.text,
    required this.sentOn,
    this.acceptedOn
  });

}
