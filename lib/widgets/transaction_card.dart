import 'package:flutter/material.dart';
import 'package:my_app/models/transaction_summary.dart';
import 'package:my_app/utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.summary,
    this.onTap,
  });

  final TransactionSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withAlpha(238),
      elevation: 10,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFECACA),
          foregroundColor: const Color(0xFF7F1D1D),
          child: Text(
            summary.id.toString(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(
          summary.partnerName,
          style: const TextStyle(
            color: Color(0xFF7F1D1D),
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${summary.label}: ${summary.partnerName}\n${formatDate(summary.date)} • ${summary.itemCount} detail item',
          style: const TextStyle(
            color: Color(0xFF7C2D12),
            fontWeight: FontWeight.w600,
          ),
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(summary.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFB91C1C),
              ),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Lihat detail',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F1D1D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
