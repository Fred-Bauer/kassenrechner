import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';

/// Manages the hidden tap-streak easter egg on the total header.
///
/// Create one instance, listen to it for rebuilds, and call [handleTap]
/// whenever the header is tapped. Use [showEasterEgg] and [message] to
/// drive the UI, and pass [confettiController] to the confetti overlay.
class EasterEggController extends ChangeNotifier {
  static const int _tapCount = 5;
  static const int _tapWindowMs = 250;
  static const int _confettiDurationMs = 400;
  static const int _initialTextDurationMs = 3000;
  static const int _textExtendMs = 1000;

  /// The message displayed when the easter egg is active.
  static const String message = '♥️ Hab dich lieb Fiene <3 ♥️';

  late final ConfettiController confettiController;

  int _tapStreak = 0;
  bool _showEasterEgg = false;
  bool _disposed = false;

  DateTime? _lastTapAt;
  DateTime? _textVisibleUntil;
  Timer? _textHideTimer;

  bool get showEasterEgg => _showEasterEgg;

  EasterEggController() {
    confettiController = ConfettiController(
      duration: const Duration(milliseconds: _confettiDurationMs),
    );
  }

  /// Call this whenever the header receives a tap.
  void handleTap() {
    if (_showEasterEgg) {
      _handleTapDuringActive();
      return;
    }

    final now = DateTime.now();
    final withinWindow = _lastTapAt != null &&
        now.difference(_lastTapAt!).inMilliseconds <= _tapWindowMs;

    _tapStreak = withinWindow ? _tapStreak + 1 : 1;
    _lastTapAt = now;

    if (_tapStreak >= _tapCount) {
      _trigger();
    }
  }

  void _handleTapDuringActive() {
    confettiController.stop();
    confettiController.play();
    _extendBy(const Duration(milliseconds: _textExtendMs));
  }

  void _trigger() {
    _tapStreak = 0;
    _lastTapAt = null;
    confettiController.stop();
    confettiController.play();
    _extendBy(const Duration(milliseconds: _initialTextDurationMs));
  }

  void _extendBy(Duration extension) {
    final now = DateTime.now();
    final base =
        _textVisibleUntil != null && _textVisibleUntil!.isAfter(now)
            ? _textVisibleUntil!
            : now;

    _textVisibleUntil = base.add(extension);
    _textHideTimer?.cancel();

    if (!_showEasterEgg) {
      _showEasterEgg = true;
      _notifyIfActive();
    }

    _textHideTimer = Timer(_textVisibleUntil!.difference(now), () {
      _showEasterEgg = false;
      _textVisibleUntil = null;
      _notifyIfActive();
    });
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _textHideTimer?.cancel();
    confettiController.dispose();
    super.dispose();
  }
}
