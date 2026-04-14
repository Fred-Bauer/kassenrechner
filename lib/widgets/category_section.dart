import 'package:flutter/material.dart';

import '../models/cash_models.dart';
import 'counter_row.dart';

/// Card-like section that groups all counters for one category.
class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.category,
    required this.counts,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CashCategory category;
  final Map<String, int> counts;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in category.items)
            CounterRow(
              title: item.label,
              value: item.value,
              count: counts[item.id] ?? 0,
              onIncrement: () => onIncrement(item.id),
              onDecrement: () => onDecrement(item.id),
            ),
        ],
      ),
    );
  }
}
