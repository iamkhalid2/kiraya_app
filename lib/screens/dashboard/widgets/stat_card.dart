import 'package:flutter/material.dart';
import 'package:countup/countup.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String? suffix;
  final bool isPercentage;
  final bool isCurrency;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix,
    this.isPercentage = false,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrency) 
                  Text(
                    '₹',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  isPercentage
                      ? value.toStringAsFixed(1)
                      : value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPercentage)
                  Text(
                    '%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (suffix != null)
                  Text(
                    ' $suffix',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
