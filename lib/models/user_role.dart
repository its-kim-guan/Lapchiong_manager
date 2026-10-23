enum UserRole {
  admin(
    label: 'Admin',
    description: 'Kelola barang, pembelian, penjualan, dan pantau growth bisnis.',
  ),
  cashier(
    label: 'Cashier',
    description: 'Fokus menjual barang dan memantau transaksi penjualan harian.',
  );

  const UserRole({
    required this.label,
    required this.description,
  });

  final String label;
  final String description;

  bool get canManageItems => this == UserRole.admin;
  bool get canManagePurchases => this == UserRole.admin;
  bool get canViewReports => this == UserRole.admin;
  bool get canSellItems => this == UserRole.admin || this == UserRole.cashier;
}
