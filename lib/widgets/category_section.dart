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

  /// Builds one counter tile and supports a wider style for special items.
  Widget _buildCounterTile(
    CashItem item,
    String itemTitle, {
    bool isWide = false,
    required double tileAspectRatio,
  }) {
    return AspectRatio(
      aspectRatio: isWide ? tileAspectRatio * 2 : tileAspectRatio,
      child: CounterRow(
        title: itemTitle,
        value: item.value,
        count: counts[item.id] ?? 0,
        backgroundColor: item.cardColor,
        borderColor: item.borderColor,
        borderWidth: item.borderWidth,
        showValueLine: !category.useValueAsLabel,
        isCoin: category.title == 'Münzen',
        isRoll: category.title == 'Rollen',
        onIncrement: () => onIncrement(item.id),
        onDecrement: () => onDecrement(item.id),
        onSetCount: (count) => onSetCount(item.id, count),
      ),
    );
  }

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
                    fontWeight: FontWeight.w900,
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
          // Render as paired rows so specific items can span full width.
          LayoutBuilder(
            builder: (context, constraints) {
              // Only use one-column mode in real emergency width situations.
              final isEmergencyWidth = constraints.maxWidth < 320;
              final useSingleColumn = isEmergencyWidth && category.title == 'Rollen';
              // Outside emergency mode, keep two columns and only make tiles a bit taller.
              final tileAspectRatio = constraints.maxWidth < 360 ? 1.75 : 1.95;
              final rows = <Widget>[];

              if (useSingleColumn) {
                for (final item in sortedItems) {
                  final itemTitle = category.useValueAsLabel
                      ? formatValueLabel(item.value)
                      : item.label;
                  rows.add(
                    _buildCounterTile(
                      item,
                      itemTitle,
                      tileAspectRatio: tileAspectRatio,
                    ),
                  );
                }
              } else {
                for (var i = 0; i < sortedItems.length; i += 2) {
                  final left = sortedItems[i];
                  final isLastSingle = i == sortedItems.length - 1;
                  final leftTitle = category.useValueAsLabel
                      ? formatValueLabel(left.value)
                      : left.label;

                  if (isLastSingle && category.title == 'Scheine' && left.id == 'schein_500') {
                    // The final 500 EUR note spans full width for a balanced odd-count layout.
                    rows.add(
                      _buildCounterTile(
                        left,
                        leftTitle,
                        isWide: true,
                        tileAspectRatio: tileAspectRatio,
                      ),
                    );
                    continue;
                  }

                  if (isLastSingle) {
                    rows.add(
                      Row(
                        children: [
                          Expanded(
                            child: _buildCounterTile(
                              left,
                              leftTitle,
                              tileAspectRatio: tileAspectRatio,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    );
                    continue;
                  }

                  final right = sortedItems[i + 1];
                  final rightTitle = category.useValueAsLabel
                      ? formatValueLabel(right.value)
                      : right.label;

                  rows.add(
                    Row(
                      children: [
                        Expanded(
                          child: _buildCounterTile(
                            left,
                            leftTitle,
                            tileAspectRatio: tileAspectRatio,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCounterTile(
                            right,
                            rightTitle,
                            tileAspectRatio: tileAspectRatio,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }

              return Column(
                children: [
                  for (var r = 0; r < rows.length; r++) ...[
                    rows[r],
                    if (r != rows.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
