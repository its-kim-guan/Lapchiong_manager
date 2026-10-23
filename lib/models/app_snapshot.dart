import 'package:my_app/models/inventory_item.dart';
import 'package:my_app/models/profit_loss_report.dart';
import 'package:my_app/models/transaction_summary.dart';

class AppSnapshot {
  const AppSnapshot({
    required this.items,
    required this.purchases,
    required this.sales,
    required this.report,
    required this.totalItems,
    required this.totalStock,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalProfit,
    required this.totalInventoryValue,
    required this.lowStockCount,
  });

  final List<InventoryItem> items;
  final List<TransactionSummary> purchases;
  final List<TransactionSummary> sales;
  final ProfitLossReport report;
  final int totalItems;
  final int totalStock;
  final int totalSales;
  final int totalPurchases;
  final int totalProfit;
  final int totalInventoryValue;
  final int lowStockCount;
}
