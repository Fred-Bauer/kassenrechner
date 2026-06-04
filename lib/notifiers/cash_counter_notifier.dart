import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cash_categories.dart';

/// Holds all counting state and hold-to-reset logic.
/// Exposes [onResetComplete] so the UI can show a SnackBar after reset.
class CashCounterNotifier extends ChangeNotifier {
  /// Duration the user must hold the reset button.
  static const int resetHoldDurationMs = 2500;
  static const String _rollItemIdPrefix = 'rollen_';
  static const String _rollCountsStorageKey = 'rollen_counts_v1';

  final Map<String, int> _counts = <String, int>{};
  bool _isResetHolding = false;
  double _resetProgress = 0.0;
  bool _disposed = false;

  Timer? _resetHoldTimer;
  Timer? _resetProgressTimer;
  Timer? _rollPersistDebounceTimer;
  DateTime? _resetStartTime;

  /// Called when the hold-to-reset completes. Wire this to a SnackBar in the UI.
  VoidCallback? onResetComplete;

  CashCounterNotifier() {
    for (final category in cashCategories) {
      for (final item in category.items) {
        _counts[item.id] = 0;
      }
    }

    // Load persisted roll values without blocking first paint.
    unawaited(_loadPersistedRollCounts());
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
    if (_isRollItem(itemId)) {
      _scheduleRollCountsPersist();
    }
    _notifyIfActive();
  }

  void setCount(String itemId, int nextValue) {
    _counts[itemId] = nextValue.clamp(0, 99999);
    if (_isRollItem(itemId)) {
      _scheduleRollCountsPersist();
    }
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
      _scheduleRollCountsPersist();
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

  /// Returns true when the counter belongs to the "Rollen" section.
  bool _isRollItem(String itemId) => itemId.startsWith(_rollItemIdPrefix);

  /// Debounces storage writes so rapid taps do not trigger constant I/O.
  void _scheduleRollCountsPersist() {
    _rollPersistDebounceTimer?.cancel();
    _rollPersistDebounceTimer = Timer(const Duration(milliseconds: 250), () {
      unawaited(_persistRollCounts());
    });
  }

  /// Persists only roll counters in local storage.
  Future<void> _persistRollCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final rollCounts = <String, int>{
      for (final entry in _counts.entries)
        if (_isRollItem(entry.key)) entry.key: entry.value,
    };

    await prefs.setString(_rollCountsStorageKey, jsonEncode(rollCounts));
  }

  /// Restores persisted roll counters and keeps all other counters at 0.
  Future<void> _loadPersistedRollCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final storedJson = prefs.getString(_rollCountsStorageKey);
    if (storedJson == null || storedJson.isEmpty) {
      return;
    }

    final decoded = jsonDecode(storedJson);
    if (decoded is! Map<String, dynamic>) {
      return;
    }

    var hasChanges = false;
    for (final entry in decoded.entries) {
      final key = entry.key;
      final value = entry.value;
      if (!_isRollItem(key) || value is! num) {
        continue;
      }

      final clamped = value.toInt().clamp(0, 99999);
      if (_counts[key] != clamped) {
        _counts[key] = clamped;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      _notifyIfActive();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _resetHoldTimer?.cancel();
    _resetProgressTimer?.cancel();
    _rollPersistDebounceTimer?.cancel();
    super.dispose();
  }
}
