import 'package:flutter/material.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/widgets/widgets.dart';

class PenjualanPage extends StatelessWidget {
  const PenjualanPage({
    super.key,
    required this.items,
    required this.sales,
    required this.onCreateSale,
    required this.onOpenSaleDetail,
  });

  final List<InventoryItem> items;
  final List<TransactionSummary> sales;
  final VoidCallback onCreateSale;
  final ValueChanged<TransactionSummary> onOpenSaleDetail;

  @override
  Widget build(BuildContext context) {
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
            'Transaksi Penjualan',
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
          SectionCard(
            title: 'Alur Penjualan',
            backgroundColor: Colors.white.withAlpha(236),
            titleColor: const Color(0xFF7F1D1D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penjualan akan mengurangi stok, menyimpan harga jual transaksi, dan menghitung laba berdasarkan harga beli terakhir.',
                  style: TextStyle(
                    color: Color(0xFF7F1D1D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: items.isEmpty ? null : onCreateSale,
                  icon: const Icon(Icons.receipt),
                  label: const Text('Buat Penjualan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const EmptyState(
              message:
                  'Tambahkan barang terlebih dahulu sebelum membuat penjualan.',
              icon: Icons.inventory_outlined,
            )
          else if (sales.isEmpty)
            const EmptyState(
              message: 'Belum ada data penjualan.',
              icon: Icons.point_of_sale_outlined,
            )
          else
            ...sales.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TransactionCard(
                  summary: item,
                  onTap: () => onOpenSaleDetail(item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
