import 'package:flutter/material.dart';

/// Data model for one cash area such as rolls or bills.
class CashCategory {
  const CashCategory({
    required this.title,
    required this.backgroundColor,
    required this.items,
    this.useValueAsLabel = false,
  });

  final String title;
  final Color backgroundColor;
  final List<CashItem> items;
  final bool useValueAsLabel;
}

/// Data model for one countable unit with a fixed value.
class CashItem {
  const CashItem({
    required this.id,
    required this.label,
    required this.value,
    this.cardColor,
  });

  final String id;
  final String label;
  final double value;
  final Color? cardColor;
}
