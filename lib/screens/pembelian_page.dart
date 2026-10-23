import 'package:flutter/material.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/widgets/widgets.dart';

class PembelianPage extends StatelessWidget {
  const PembelianPage({
    super.key,
    required this.items,
    required this.purchases,
    required this.onCreatePurchase,
    required this.onOpenPurchaseDetail,
  });

  final List<InventoryItem> items;
  final List<TransactionSummary> purchases;
  final VoidCallback onCreatePurchase;
  final ValueChanged<TransactionSummary> onOpenPurchaseDetail;

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
            'Transaksi Pembelian',
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
            title: 'Alur Pembelian',
            backgroundColor: Colors.white.withAlpha(236),
            titleColor: const Color(0xFF7F1D1D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pembelian akan menambah stok barang dan memperbarui harga beli terakhir pada item yang dipilih.',
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
                  onPressed: items.isEmpty ? null : onCreatePurchase,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Buat Pembelian'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const EmptyState(
              message:
                  'Tambahkan barang terlebih dahulu sebelum membuat pembelian.',
              icon: Icons.inventory_outlined,
            )
          else if (purchases.isEmpty)
            const EmptyState(
              message: 'Belum ada data pembelian.',
              icon: Icons.shopping_cart_checkout_outlined,
            )
          else
            ...purchases.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TransactionCard(
                  summary: item,
                  onTap: () => onOpenPurchaseDetail(item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
