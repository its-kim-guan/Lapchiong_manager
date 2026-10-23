class ProfitLossReport {
  const ProfitLossReport({
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalPurchases,
    required this.hpp,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int totalSales;
  final int totalPurchases;
  final int hpp;

  int get grossProfit => totalSales - hpp;
}
