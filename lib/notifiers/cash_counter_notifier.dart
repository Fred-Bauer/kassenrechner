import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/cash_categories.dart';

/// Holds all counting state and hold-to-reset logic.
/// Exposes [onResetComplete] so the UI can show a SnackBar after reset.
class CashCounterNotifier extends ChangeNotifier {
  /// Duration the user must hold the reset button.
  static const int resetHoldDurationMs = 2500;

  final Map<String, int> _counts = <String, int>{};
  bool _isResetHolding = false;
  double _resetProgress = 0.0;
  bool _disposed = false;

  Timer? _resetHoldTimer;
  Timer? _resetProgressTimer;
  DateTime? _resetStartTime;

  /// Called when the hold-to-reset completes. Wire this to a SnackBar in the UI.
  VoidCallback? onResetComplete;

  CashCounterNotifier() {
    for (final category in cashCategories) {
      for (final item in category.items) {
        _counts[item.id] = 0;
      }
    }
  }

  Map<String, int> get counts => Map.unmodifiable(_counts);
  bool get isResetHolding => _isResetHolding;
  double get resetProgress => _resetProgress;

  double get totalValue {
    var total = 0.0;
    for (final category in cashCategories) {
      for (final item in category.items) {
        final count = _counts[item.id] ?? 0;
        total += item.value * count;
      }
    }
    return total;
  }

  void changeCount(String itemId, int delta) {
    final current = _counts[itemId] ?? 0;
    _counts[itemId] = (current + delta).clamp(0, 99999);
    _notifyIfActive();
  }

  void setCount(String itemId, int nextValue) {
    _counts[itemId] = nextValue.clamp(0, 99999);
    _notifyIfActive();
  }

  void startResetHold() {
    _resetHoldTimer?.cancel();
    _resetProgressTimer?.cancel();
    _resetStartTime = DateTime.now();
    _isResetHolding = true;
    _resetProgress = 0.0;
    _notifyIfActive();

    _resetProgressTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isResetHolding) {
        _resetProgressTimer?.cancel();
        return;
      }
      final elapsed =
          DateTime.now().difference(_resetStartTime!).inMilliseconds;
      _resetProgress = (elapsed / resetHoldDurationMs).clamp(0.0, 1.0);
      _notifyIfActive();
    });

    _resetHoldTimer =
        Timer(const Duration(milliseconds: resetHoldDurationMs), () {
      _resetProgressTimer?.cancel();
      for (final key in _counts.keys) {
        _counts[key] = 0;
      }
      _isResetHolding = false;
      _resetProgress = 0.0;
      _notifyIfActive();
      if (!_disposed) {
        onResetComplete?.call();
      }
    });
  }

  void cancelResetHold() {
    _resetHoldTimer?.cancel();
    _resetProgressTimer?.cancel();
    if (!_isResetHolding) return;
    _isResetHolding = false;
    _resetProgress = 0.0;
    _notifyIfActive();
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _resetHoldTimer?.cancel();
    _resetProgressTimer?.cancel();
    super.dispose();
  }
}
