class TransactionDetailRecord {
  const TransactionDetailRecord({
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.purchasePrice,
    required this.subtotal,
    this.salePrice,
    this.profit,
  });

  final String itemName;
  final String category;
  final int quantity;
  final int purchasePrice;
  final int? salePrice;
  final int subtotal;
  final int? profit;

  factory TransactionDetailRecord.fromPurchaseMap(Map<String, Object?> map) {
    return TransactionDetailRecord(
      itemName: map['nama'] as String,
      category: map['kategori'] as String,
      quantity: (map['jumlah'] as num).toInt(),
      purchasePrice: (map['harga_beli'] as num).toInt(),
      subtotal: (map['subtotal'] as num).toInt(),
    );
  }

  factory TransactionDetailRecord.fromSaleMap(Map<String, Object?> map) {
    return TransactionDetailRecord(
      itemName: map['nama'] as String,
      category: map['kategori'] as String,
      quantity: (map['jumlah'] as num).toInt(),
      purchasePrice: (map['harga_beli'] as num).toInt(),
      salePrice: (map['harga_jual'] as num).toInt(),
      subtotal: (map['subtotal'] as num).toInt(),
      profit: (map['laba'] as num).toInt(),
    );
  }
}
