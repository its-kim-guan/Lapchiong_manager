import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor,
    this.titleColor,
  });

  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
