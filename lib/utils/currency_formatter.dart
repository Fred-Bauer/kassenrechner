/// Formats numeric money values into a readable EUR string.
String formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
  return '$fixed EUR';
}
