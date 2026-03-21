/// Represents a purchasable item in the game, which can be bought with real money.
abstract class PurchasableItem {

  /// The ID of the item.
  String id;

  /// The name of the item.
  String name;

  /// A brief description of the item.
  String description;

  /// The cost of the item.
  double cost;

  PurchasableItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });

}