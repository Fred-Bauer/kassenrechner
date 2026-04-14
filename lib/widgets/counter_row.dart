import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';

/// Single quick counter row with minus and plus actions.
class CounterRow extends StatelessWidget {
  const CounterRow({
    super.key,
    required this.title,
    required this.value,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String title;
  final double value;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowSum = value * count;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Wert: ${formatCurrency(value)}  |  Summe: ${formatCurrency(rowSum)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove),
            tooltip: 'Verringern',
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton.filled(
            onPressed: onIncrement,
            icon: const Icon(Icons.add),
            tooltip: 'Erhoehen',
          ),
        ],
      ),
    );
  }
}
