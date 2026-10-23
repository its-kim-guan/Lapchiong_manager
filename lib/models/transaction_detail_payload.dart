import 'package:my_app/models/inventory_item.dart';

class TransactionDetailPayload {
  const TransactionDetailPayload({
    required this.item,
    required this.quantity,
    required this.unitPrice,
  });

  final InventoryItem item;
  final int quantity;
  final int unitPrice;

  int get subtotal => quantity * unitPrice;
}
