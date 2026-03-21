/// Represents an offer for a collection of or a single purchasable item.
abstract class PurchaseOffer {

  /// The ID of the offer.
  String id;

  /// The name of the offer.
  String name;

  /// A brief description of the offer.
  String description;

  /// The timestamp when the offer starts.
  int startTimestamp;

  /// The timestamp when the offer ends, if it has an end date.
  int? endTimestamp;

  /// The normal cost of the offer.
  double normalCost;

  /// The discount percentage of the offer.
  double discountPercentage; //0-1

  /// The IDs of the purchasable items associated with the offer.
  List<String> purchasableItemIDs;

  PurchaseOffer({
    required this.id,
    required this.name,
    required this.description,
    required this.startTimestamp,
    required this.purchasableItemIDs,
    this.endTimestamp,
    required this.normalCost,
    required this.discountPercentage,
  }) : assert(
  discountPercentage >= 0 && discountPercentage <= 1,
  'discountPercentage must be between 0 and 1',
  ) {
    if (discountPercentage < 0 || discountPercentage > 1) {
      throw ArgumentError.value(
        discountPercentage,
        'discountPercentage',
        'Must be between 0 and 1',
      );
    }
  }

}