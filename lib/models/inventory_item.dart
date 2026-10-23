import 'package:my_app/utils/app_constants.dart';

class InventoryItem {
  const InventoryItem({
    this.id,
    required this.name,
    required this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
  });

  final int? id;
  final String name;
  final String category;
  final int purchasePrice;
  final int salePrice;
  final int stock;

  int get margin => salePrice - purchasePrice;
  bool get isLowStock => stock <= lowStockThreshold;

  factory InventoryItem.fromMap(Map<String, Object?> map) {
    return InventoryItem(
      id: (map['id'] as num?)?.toInt(),
      name: map['nama'] as String,
      category: map['kategori'] as String,
      purchasePrice: (map['harga_beli'] as num).toInt(),
      salePrice: (map['harga_jual'] as num).toInt(),
      stock: (map['stok'] as num).toInt(),
    );
  }
}
