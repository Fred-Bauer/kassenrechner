import 'package:flutter/material.dart';

/// A button widget that requires a long hold gesture to trigger a reset action.
///
/// Visual feedback changes during the hold: the button transitions from
/// surfaceContainer to errorContainer color, shows a fill animation,
/// and the text updates to indicate the required sustained action.
class ResetButton extends StatelessWidget {
  /// Whether the hold gesture is currently in progress.
  final bool isHolding;

  /// Progress value from 0.0 to 1.0 indicating hold completion.
  final double progress;

  /// Callback triggered when the user presses down on the button.
  final VoidCallback onTapDown;

  /// Callback triggered when the user releases the button normally.
  final VoidCallback onTapUp;

  /// Callback triggered when the user cancels the gesture (e.g., drags away).
  final VoidCallback onTapCancel;

  const ResetButton({
    super.key,
    required this.isHolding,
    required this.progress,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = isHolding
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.surfaceContainer;

    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapCancel,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.55),
          ),
        ),
        child: Stack(
          children: [
            // Progress bar background fill
            if (isHolding)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.colorScheme.error.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            // Text on top
            Center(
              child: Text(
                isHolding
                    ? 'Halten für Reset...'
                    : 'Reset',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isHolding
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
