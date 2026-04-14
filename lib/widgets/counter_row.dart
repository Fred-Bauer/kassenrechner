import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/currency_formatter.dart';

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
    if (widget.isCoin) {
      return _showCoinSetDialog(context);
    }

    final controller = TextEditingController(text: '${widget.count}');

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Anzahl',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final parsed = int.tryParse(value.trim());
              if (parsed != null && parsed >= 0) {
                Navigator.of(context).pop(parsed);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed != null && parsed >= 0) {
                  Navigator.of(context).pop(parsed);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      widget.onSetCount(result);
    }
  }

  /// Opens a dual-field dialog for coins (sum and count fields).
  Future<void> _showCoinSetDialog(BuildContext context) async {
    final sumController = TextEditingController();
    final countController = TextEditingController(text: '${widget.count}');

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.title),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sumController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Summe (€)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          countController.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: countController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Anzahl',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          sumController.clear();
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                final sumText = sumController.text.trim();
                final countText = countController.text.trim();

                int parsed = 0;

                if (sumText.isNotEmpty) {
                  // Sum was entered, calculate count from it
                  final sum = double.tryParse(sumText);
                  if (sum != null && sum >= 0) {
                    parsed = (sum / widget.value).round();
                  } else {
                    return;
                  }
                } else if (countText.isNotEmpty) {
                  // Count was entered
                  parsed = int.tryParse(countText) ?? 0;
                  if (parsed < 0) {
                    return;
                  }
                }

                Navigator.of(context).pop(parsed);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
    final textIsDark = ThemeData.estimateBrightnessForColor(baseColor) ==
        Brightness.light;
    final textColor = textIsDark ? Colors.black87 : Colors.white;
    final subTextColor = textIsDark ? Colors.black54 : Colors.white70;
    final resolvedBorderColor =
      widget.borderColor ?? Colors.white.withValues(alpha: 0.5);
    final resolvedBorderWidth = widget.borderWidth ?? 1.0;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Tap adds one quickly, long press opens direct number entry.
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
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: resolvedBorderColor,
                width: resolvedBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  const SizedBox(height: 1),
                  Text(
                    formatCurrency(widget.value),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: subTextColor,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                // Count and sum are grouped for quicker readout.
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {
                        widget.onDecrement();
                        _hapticSelection();
                      },
                      icon: const Icon(Icons.remove),
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                      style: IconButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.white.withValues(alpha: 0.88),
                        foregroundColor: Colors.black87,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
