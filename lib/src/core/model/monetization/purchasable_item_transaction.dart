/// Represents a transaction for a purchasable item.
abstract class PurchasableItemTransaction {

  /// The ID of the transaction.
  String id;

  /// The IDs of the purchasable items in the transaction.
  List<String> purchasableItemIDs;

  /// The ID of the player who made the transaction.
  String playerID;

  /// The total amount of the items purchased.
  double amount;

  PurchasableItemTransaction({
    required this.id,
    required this.purchasableItemIDs,
    required this.playerID,
    required this.amount,
  });

}
