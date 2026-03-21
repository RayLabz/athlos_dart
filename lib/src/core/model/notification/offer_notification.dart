import 'notification.dart';

/// A notification for an offer.
abstract class OfferNotification extends Notification {

  /// The offer's ID.
  String offerID;

  OfferNotification({
    required super.id,
    required super.name,
    required super.description,
    required super.createdOnTimestamp,
    super.hasBeenRead = false,
    required this.offerID,
  });

}