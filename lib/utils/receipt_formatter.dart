import '../models/cash_models.dart';
import 'currency_formatter.dart';

// Toggle whether lines with count 0 should be part of the copied receipt.
const bool includeZeroCountItemsInReceipt = false;

// Main header text for copied receipts.
const String receiptTitle = 'Kassenabrechnung';

// Section divider used in copied receipt text.
const String receiptDivider = '--------------------------------';

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
    var categorySubtotal = 0.0;
    final categoryLines = <String>[];

    for (final item in category.items) {
      final count = counts[item.id] ?? 0;
      if (!includeZeroCountItemsInReceipt && count == 0) {
        continue;
      }

      final rowSum = item.value * count;
      categorySubtotal += rowSum;
      categoryLines.add('${count}x ${item.label} = ${formatCurrency(rowSum)}');
    }

    lines.add('${category.title}: ${formatCurrency(categorySubtotal)}');
    lines.addAll(categoryLines);
    lines.add('');
  }

  lines.add(receiptDivider);
  lines.add('GESAMT: ${formatCurrency(totalValue)}');
  lines.add('GESAMT-1500: ${formatCurrency(totalValue - 1500)}');

  return lines.join('\n');
}
