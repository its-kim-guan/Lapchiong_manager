import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.backgroundColor,
    this.titleColor,
    this.valueColor,
    this.subtitleColor,
    this.iconTintColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? valueColor;
  final Color? subtitleColor;
  final Color? iconTintColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        color: backgroundColor,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(38),
                foregroundColor: iconTintColor ?? color,
                child: Icon(icon),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: titleColor),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: subtitleColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
