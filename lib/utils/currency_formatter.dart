/// Formats numeric money values into a readable EUR string.
String formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2);
  final compact = fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '')
      .replaceAll('.', ',');
  return '$compact €';
}

/// Formats a unit value label like '5 €' or '0,5 €'.
String formatValueLabel(double value) {
  final asText = value.toStringAsFixed(2);
  final compact = asText
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '')
      .replaceAll('.', ',');
  return '$compact €';
}
