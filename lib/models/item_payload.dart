class ItemPayload {
  const ItemPayload({
    required this.name,
    required this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
  });

  final String name;
  final String category;
  final int purchasePrice;
  final int salePrice;
  final int stock;
}
