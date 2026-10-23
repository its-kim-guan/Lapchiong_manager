import 'package:flutter/material.dart';

class ReportTile extends StatelessWidget {
  const ReportTile({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB91C1C),
          )
        : Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF450A0A));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7F1D1D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
