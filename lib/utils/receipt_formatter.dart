import '../models/cash_models.dart';
import 'currency_formatter.dart';

// Toggle whether lines with count 0 should be part of the copied receipt.
const bool includeZeroCountItemsInReceipt = false;

// Main header text for copied receipts.
const String receiptTitle = 'Kassenabrechnung';

// Section divider used in copied receipt text.
const String receiptDivider = '--------------------------------';

// Layout controls for fixed-width receipt columns.
const int receiptCountColumnWidth = 7;
const int receiptLabelColumnWidth = 20;

/// Builds the full receipt text that is copied to the clipboard.
String buildReceiptText({
  required List<CashCategory> categories,
  required Map<String, int> counts,
  required double totalValue,
}) {
  final lines = <String>[
    receiptTitle,
    receiptDivider,
  ];

  for (final category in categories) {
    final itemRows = <({CashItem item, int count, double rowSum})>[];
    var categorySubtotal = 0.0;

    for (final item in category.items) {
      final count = counts[item.id] ?? 0;
      if (!includeZeroCountItemsInReceipt && count == 0) {
        continue;
      }

      final rowSum = item.value * count;
      categorySubtotal += rowSum;
      itemRows.add((item: item, count: count, rowSum: rowSum));
    }

    lines.add('${category.title}: ${formatCurrency(categorySubtotal)}');
    for (final row in itemRows) {
      lines.add(_formatReceiptItemLine(
        count: row.count,
        label: row.item.label,
        rowSum: row.rowSum,
      ));
    }
    lines.add('');
  }

  lines.add(receiptDivider);
  lines.add('GESAMT: ${formatCurrency(totalValue)}');

  return lines.join('\n');
}

/// Formats one receipt row with fixed-width columns for consistent alignment.
String _formatReceiptItemLine({
  required int count,
  required String label,
  required double rowSum,
}) {
  final countColumn = '${count}x'.padRight(receiptCountColumnWidth);
  final labelColumn = label.padRight(receiptLabelColumnWidth);
  return '  $countColumn$labelColumn ${formatCurrency(rowSum)}';
}
