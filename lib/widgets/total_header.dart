import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';

/// Sticky top card that always displays the full cash total.
class TotalHeader extends StatelessWidget {
  const TotalHeader({
    super.key,
    required this.totalValue,
    this.onTap,
    this.onTapDown,
    this.onLongPress,
    this.centerMessage,
    this.subtractAmount,
  });

  final double totalValue;
  final VoidCallback? onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onLongPress;
  final String? centerMessage;

  /// When set, subtracts this amount from [totalValue] and adjusts the label.
  final double? subtractAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(        onTap: onTap,        onTapDown: onTapDown != null ? (_) => onTapDown!() : null,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 38,
            child: centerMessage != null
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        centerMessage!,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subtractAmount != null
                            ? 'GESAMT – ${formatCurrency(subtractAmount!)}'
                            : 'GESAMT',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: subtractAmount != null
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        formatCurrency(
                          subtractAmount != null
                              ? totalValue - subtractAmount!
                              : totalValue,
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: subtractAmount != null
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
