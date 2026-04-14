import 'package:flutter/material.dart';

import '../models/cash_models.dart';
import '../utils/currency_formatter.dart';
import 'counter_row.dart';

/// Card-like section that groups all counters for one category.
class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.category,
    required this.counts,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSetCount,
  });

  final CashCategory category;
  final Map<String, int> counts;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final void Function(String itemId, int count) onSetCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Always render from low value to high value for faster counting flow.
    final sortedItems = [...category.items]
      ..sort((a, b) => a.value.compareTo(b.value));
    // Category subtotal gives quick feedback while counting.
    final subtotal = category.items.fold<double>(
      0,
      (sum, item) => sum + ((counts[item.id] ?? 0) * item.value),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  formatCurrency(subtotal),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Two columns keep the screen compact and easier to scan.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.95,
            ),
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              // Bills and coins can derive labels directly from their value.
              final itemTitle = category.useValueAsLabel
                  ? formatValueLabel(item.value)
                  : item.label;
              return CounterRow(
                title: itemTitle,
                value: item.value,
                count: counts[item.id] ?? 0,
                backgroundColor: item.cardColor,
                showValueLine: !category.useValueAsLabel,
                onIncrement: () => onIncrement(item.id),
                onDecrement: () => onDecrement(item.id),
                onSetCount: (count) => onSetCount(item.id, count),
              );
            },
          ),
        ],
      ),
    );
  }
}
