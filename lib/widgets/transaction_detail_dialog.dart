import 'package:flutter/material.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/utils/formatters.dart';

class TransactionDetailDialog extends StatelessWidget {
  const TransactionDetailDialog({
    super.key,
    required this.summary,
    required this.detailsFuture,
    required this.isSale,
  });

  final TransactionSummary summary;
  final Future<List<TransactionDetailRecord>> detailsFuture;
  final bool isSale;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Detail ${isSale ? 'Penjualan' : 'Pembelian'} #${summary.id}'),
      content: SizedBox(
        width: 640,
        child: FutureBuilder<List<TransactionDetailRecord>>(
          future: detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Text('Gagal memuat detail:\n${snapshot.error}');
            }

            final details = snapshot.data ?? const <TransactionDetailRecord>[];
            final totalProfit = details.fold<int>(
              0,
              (sum, detail) => sum + (detail.profit ?? 0),
            );

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: summary.label, value: summary.partnerName),
                  _InfoRow(label: 'Tanggal', value: formatDate(summary.date)),
                  _InfoRow(
                    label: 'Total transaksi',
                    value: formatCurrency(summary.total),
                    emphasize: true,
                  ),
                  if (isSale)
                    _InfoRow(
                      label: 'Total laba',
                      value: formatCurrency(totalProfit),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Item Transaksi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (details.isEmpty)
                    const Text('Tidak ada detail item.')
                  else
                    ...details.map(
                      (detail) => Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text('Kategori: ${detail.category}'),
                              const SizedBox(height: 4),
                              Text('Jumlah: ${detail.quantity}'),
                              const SizedBox(height: 4),
                              Text(
                                isSale
                                    ? 'Harga beli: ${formatCurrency(detail.purchasePrice)}'
                                    : 'Harga beli transaksi: ${formatCurrency(detail.purchasePrice)}',
                              ),
                              if (detail.salePrice != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Harga jual: ${formatCurrency(detail.salePrice!)}',
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Subtotal: ${formatCurrency(detail.subtotal)}',
                              ),
                              if (detail.profit != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Laba: ${formatCurrency(detail.profit!)}',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: emphasize ? 15 : 14,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
