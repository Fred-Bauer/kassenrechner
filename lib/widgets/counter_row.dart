import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/currency_formatter.dart';
import 'counter_set_dialogs.dart';

/// Single quick counter card with tap and long-press actions.
class CounterRow extends StatefulWidget {
  const CounterRow({
    super.key,
    required this.title,
    required this.value,
    required this.count,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.showValueLine = true,
    this.isCoin = false,
    this.isRoll = false,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSetCount,
  });

  final String title;
  final double value;
  final int count;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final bool showValueLine;
  final bool isCoin;
  final bool isRoll;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onSetCount;

  @override
  State<CounterRow> createState() => _CounterRowState();
}

class _CounterRowState extends State<CounterRow> {
  double _scale = 1.0;

  /// Triggers subtle haptics on supported mobile platforms.
  Future<void> _hapticSelection() async {
    if (kIsWeb) {
      return;
    }
    await HapticFeedback.selectionClick();
  }

  /// Triggers a stronger haptic signal for long-press interactions.
  Future<void> _hapticLongPress() async {
    if (kIsWeb) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }

  /// Triggers a short pulse and highlight for better tap feedback.
  void _animateTapFeedback() {
    setState(() {
      _scale = 1.03;
    });

    Future<void>.delayed(const Duration(milliseconds: 110), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _scale = 1.0;
      });
    });
  }

  /// Opens a dialog to set an exact counter value via keyboard.
  Future<void> _showSetCountDialog(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => widget.isCoin
          ? CoinSetDialog(
              title: widget.title,
              coinValue: widget.value,
              initialCount: widget.count,
            )
          : CountSetDialog(title: widget.title, initialCount: widget.count),
    );
    if (result != null) {
      widget.onSetCount(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowSum = widget.value * widget.count;
    // Keep per-item colors but make them flatter and lighter.
    final rawColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final baseColor = Color.lerp(rawColor, Colors.white, 0.45) ?? rawColor;
    final textIsDark =
        ThemeData.estimateBrightnessForColor(baseColor) == Brightness.light;
    final textColor = textIsDark ? Colors.black87 : Colors.white;
    final subTextColor = textIsDark ? Colors.black54 : Colors.white70;
    final hasRingBorder = widget.borderColor != null;
    final resolvedBorderColor =
        widget.borderColor ?? Colors.white.withValues(alpha: 0.5);
    final resolvedBorderWidth = widget.borderWidth ?? 1.0;

    // Build the content column – identical for ALL items, ring coins included.
    Widget content = Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isRoll && widget.showValueLine) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${formatCurrency(widget.value)})',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Label is intentionally larger and centered for fast scanning.
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showValueLine) ...[
              Text(
                formatCurrency(widget.value),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: subTextColor,
                ),
              ),
            ],
          ],
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    widget.onDecrement();
                    _hapticSelection();
                  },
                  icon: const Icon(Icons.remove),
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.count}x',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatCurrency(rowSum),
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // For ring coins the border is purely decorative: rendered behind the
    // content via a Stack so it never affects layout or scaling.
    Widget card;
    if (hasRingBorder) {
      card = Stack(
        fit: StackFit.expand,
        children: [
          // Background: base colour + decorative ring border
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: resolvedBorderColor,
                  width: resolvedBorderWidth,
                ),
              ),
            ),
          ),
          // Foreground: content laid out exactly like every other card
          content,
        ],
      );
    } else {
      card = Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: resolvedBorderColor,
            width: resolvedBorderWidth,
          ),
        ),
        child: content,
      );
    }

    // Veil overlay when count is 0 – drawn on top of everything including the ring.
    if (widget.count == 0) {
      card = DecoratedBox(
        decoration: const BoxDecoration(),
        child: Stack(
          children: [
            card,
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onIncrement();
            _hapticSelection();
            _animateTapFeedback();
          },
          onLongPress: () {
            _hapticLongPress();
            _showSetCountDialog(context);
          },
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.transparent,
          child: card,
        ),
      ),
    );
  }
}
