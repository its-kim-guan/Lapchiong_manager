import 'package:flutter/material.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/utils/formatters.dart';
import 'package:my_app/widgets/widgets.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key, required this.report, required this.snapshot});

  final ProfitLossReport report;
  final AppSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final note = report.grossProfit >= 0
        ? 'Performa masih sehat. Pertahankan margin dan jaga stok produk terlaris.'
        : 'Laba masih negatif. Cek ulang harga jual, HPP, dan volume transaksi.';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF600D12), Color(0xFF8F1218), Color(0xFFC2410C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Laporan Laba Rugi',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0xCC7F1D1D),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SummaryCard(
                title: 'Penjualan',
                value: formatCurrency(report.totalSales),
                icon: Icons.sell_outlined,
                color: Colors.white.withValues(alpha: 0.20),
                backgroundColor: const Color(0xFFD62828),
                titleColor: Colors.white,
                valueColor: Colors.white,
                subtitleColor: const Color(0xFFFFE7E2),
                iconTintColor: Colors.white,
              ),
              SummaryCard(
                title: 'Pembelian',
                value: formatCurrency(report.totalPurchases),
                icon: Icons.shopping_bag_outlined,
                color: Colors.white.withValues(alpha: 0.20),
                backgroundColor: const Color(0xFFD62828),
                titleColor: Colors.white,
                valueColor: Colors.white,
                subtitleColor: const Color(0xFFFFE7E2),
                iconTintColor: Colors.white,
              ),
              SummaryCard(
                title: 'Laba Kotor',
                value: formatCurrency(report.grossProfit),
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.white.withValues(alpha: 0.20),
                backgroundColor: const Color(0xFFD62828),
                titleColor: Colors.white,
                valueColor: Colors.white,
                subtitleColor: const Color(0xFFFFE7E2),
                iconTintColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Hasil Perhitungan',
            backgroundColor: Colors.white.withAlpha(236),
            titleColor: const Color(0xFF7F1D1D),
            child: Column(
              children: [
                ReportTile(
                  label: 'Periode',
                  value:
                      '${formatDate(report.startDate)} - ${formatDate(report.endDate)}',
                ),
                ReportTile(
                  label: 'Total Penjualan',
                  value: formatCurrency(report.totalSales),
                ),
                ReportTile(
                  label: 'Total Pembelian',
                  value: formatCurrency(report.totalPurchases),
                ),
                ReportTile(
                  label: 'Harga Pokok Penjualan',
                  value: formatCurrency(report.hpp),
                ),
                ReportTile(
                  label: 'Laba Kotor',
                  value: formatCurrency(report.grossProfit),
                  emphasize: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Catatan Bisnis',
            backgroundColor: Colors.white.withAlpha(236),
            titleColor: const Color(0xFF7F1D1D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note,
                  style: const TextStyle(
                    color: Color(0xFF7F1D1D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total produk aktif: ${snapshot.totalItems} | Stok saat ini: ${snapshot.totalStock} unit',
                  style: const TextStyle(
                    color: Color(0xFF450A0A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
