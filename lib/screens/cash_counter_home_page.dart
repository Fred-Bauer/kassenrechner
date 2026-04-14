import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cash_categories.dart';
import '../utils/receipt_formatter.dart';
import '../widgets/category_section.dart';
import '../widgets/reset_button.dart';
import '../widgets/total_header.dart';

/// Main counting screen with section scrolling and total updates.
class CashCounterHomePage extends StatefulWidget {
  const CashCounterHomePage({super.key});

  @override
  State<CashCounterHomePage> createState() => _CashCounterHomePageState();
}

/// Holds counting state and scroll navigation behavior.
class _CashCounterHomePageState extends State<CashCounterHomePage> {
  /// Duration in milliseconds that user must hold the button to trigger reset.
  static const int resetHoldDurationMs = 3000;

  final ScrollController _scrollController = ScrollController();
  Timer? _resetHoldTimer;
  Timer? _resetProgressTimer;
  DateTime? _resetStartTime;
  double _resetProgress = 0.0;
  final List<GlobalKey> _sectionKeys = List<GlobalKey>.generate(
    cashCategories.length,
    (_) => GlobalKey(),
  );

  final Map<String, int> _counts = <String, int>{};
  int _currentSection = 0;
  bool _isResetHolding = false;

  @override
  void initState() {
    super.initState();
    for (final category in cashCategories) {
      for (final item in category.items) {
        _counts[item.id] = 0;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentSectionFromScroll();
    });
  }

  @override
  void dispose() {
    _resetHoldTimer?.cancel();
    _resetProgressTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// Computes the full sum based on all category item counts.
  double get _totalValue {
    var total = 0.0;
    for (final category in cashCategories) {
      for (final item in category.items) {
        final count = _counts[item.id] ?? 0;
        total += item.value * count;
      }
    }
    return total;
  }

  /// Updates one item count while keeping values non-negative.
  void _changeCount(String itemId, int delta) {
    final current = _counts[itemId] ?? 0;
    final next = (current + delta).clamp(0, 99999);
    setState(() {
      _counts[itemId] = next;
    });
  }

  /// Sets one item count directly from manual number input.
  void _setCount(String itemId, int nextValue) {
    final next = nextValue.clamp(0, 99999);
    setState(() {
      _counts[itemId] = next;
    });
  }

  /// Copies the current full receipt text to the system clipboard.
  Future<void> _copyReceiptToClipboard() async {
    final receipt = buildReceiptText(
      categories: cashCategories,
      counts: _counts,
      totalValue: _totalValue,
    );

    await Clipboard.setData(ClipboardData(text: receipt));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rechnung wurde in die Zwischenablage kopiert.'),
      ),
    );
  }

  /// Starts a long hold gesture that resets the complete calculation.
  void _startResetHold() {
    _resetHoldTimer?.cancel();
    _resetProgressTimer?.cancel();
    _resetStartTime = DateTime.now();
    setState(() {
      _isResetHolding = true;
      _resetProgress = 0.0;
    });

    // Progress ticker: updates every 16ms for smooth animation
    _resetProgressTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isResetHolding || !mounted) {
        _resetProgressTimer?.cancel();
        return;
      }

      final elapsed =
          DateTime.now().difference(_resetStartTime!).inMilliseconds;
      final progress = (elapsed / resetHoldDurationMs).clamp(0.0, 1.0);

      setState(() {
        _resetProgress = progress;
      });
    });

    _resetHoldTimer = Timer(Duration(milliseconds: resetHoldDurationMs), () {
      if (!mounted) {
        return;
      }
      _resetProgressTimer?.cancel();

      setState(() {
        for (final key in _counts.keys) {
          _counts[key] = 0;
        }
        _isResetHolding = false;
        _resetProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rechnung wurde zurückgesetzt.')),
      );
    });
  }

  /// Cancels the reset hold when the user releases too early.
  void _cancelResetHold() {
    _resetHoldTimer?.cancel();
    _resetProgressTimer?.cancel();
    if (!_isResetHolding) {
      return;
    }
    setState(() {
      _isResetHolding = false;
      _resetProgress = 0.0;
    });
  }

  /// Smooth-scrolls to the requested section card by index.
  void _scrollToSection(int index) {
    if (index < 0 || index >= _sectionKeys.length) {
      return;
    }
    final context = _sectionKeys[index].currentContext;
    if (context == null) {
      return;
    }
    setState(() {
      _currentSection = index;
    });
    Scrollable.ensureVisible(
      context,
      alignment: 0.02,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  /// Tracks which section is currently closest to the viewport top.
  void _updateCurrentSectionFromScroll() {
    var bestIndex = _currentSection;
    var bestDistance = double.infinity;

    for (var i = 0; i < _sectionKeys.length; i++) {
      final sectionContext = _sectionKeys[i].currentContext;
      if (sectionContext == null) {
        continue;
      }
      final box = sectionContext.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) {
        continue;
      }

      final position = box.localToGlobal(Offset.zero);
      final distance = (position.dy - 130).abs();

      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    if (bestIndex != _currentSection) {
      setState(() {
        _currentSection = bestIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoUp = _currentSection > 0;
    final canGoDown = _currentSection < cashCategories.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TotalHeader(
                  totalValue: _totalValue,
                  onLongPress: _copyReceiptToClipboard,
                ),
                Expanded(
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      _updateCurrentSectionFromScroll();
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
                      itemCount: cashCategories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == cashCategories.length) {
                          return ResetButton(
                            isHolding: _isResetHolding,
                            progress: _resetProgress,
                            onTapDown: _startResetHold,
                            onTapUp: _cancelResetHold,
                            onTapCancel: _cancelResetHold,
                          );
                        }

                        final category = cashCategories[index];
                        return CategorySection(
                          key: _sectionKeys[index],
                          category: category,
                          counts: _counts,
                          onIncrement: (id) => _changeCount(id, 1),
                          onDecrement: (id) => _changeCount(id, -1),
                          onSetCount: _setCount,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 20,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'scroll-up',
                    onPressed: canGoUp
                        ? () => _scrollToSection(_currentSection - 1)
                        : null,
                    child: const Icon(Icons.keyboard_arrow_up_rounded),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'scroll-down',
                    onPressed: canGoDown
                        ? () => _scrollToSection(_currentSection + 1)
                        : null,
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
