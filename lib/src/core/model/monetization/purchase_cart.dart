/// Represents a player's cart, allowing them to purchase items.
abstract class PurchaseCart {

  /// The ID of the cart.
  String id;

  /// The IDs of the purchasable items in the cart.
  List<String> purchasableItemIDs;

  /// The ID of the player who owns the cart.
  String playerID;

  PurchaseCart({
    required this.id,
    required this.purchasableItemIDs,
    required this.playerID,
  });

}
