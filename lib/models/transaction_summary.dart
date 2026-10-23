class TransactionSummary {
  const TransactionSummary({
    required this.id,
    required this.date,
    required this.partnerName,
    required this.total,
    required this.itemCount,
    required this.label,
  });

  final int id;
  final DateTime date;
  final String partnerName;
  final int total;
  final int itemCount;
  final String label;

  factory TransactionSummary.fromPurchaseMap(Map<String, Object?> map) {
    return TransactionSummary(
      id: (map['id'] as num).toInt(),
      date: DateTime.parse(map['tanggal'] as String),
      partnerName: map['supplier'] as String,
      total: (map['total'] as num).toInt(),
      itemCount: (map['jumlah_item'] as num?)?.toInt() ?? 0,
      label: 'Supplier',
    );
  }

  factory TransactionSummary.fromSaleMap(Map<String, Object?> map) {
    return TransactionSummary(
      id: (map['id'] as num).toInt(),
      date: DateTime.parse(map['tanggal'] as String),
      partnerName: map['pelanggan'] as String,
      total: (map['total'] as num).toInt(),
      itemCount: (map['jumlah_item'] as num?)?.toInt() ?? 0,
      label: 'Pelanggan',
    );
  }
}
