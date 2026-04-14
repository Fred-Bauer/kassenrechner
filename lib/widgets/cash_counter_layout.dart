import 'package:flutter/material.dart';

import '../data/cash_categories.dart';
import '../models/cash_models.dart';
import 'category_section.dart';
import 'reset_button.dart';

/// Switches between a single-column (narrow) and three-column (wide) layout
/// at [wideBreakpoint] pixels. All state is received via constructor params.
class CashCounterLayout extends StatelessWidget {
  const CashCounterLayout({
    super.key,
    required this.counts,
    required this.isResetHolding,
    required this.resetProgress,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSetCount,
    required this.onResetTapDown,
    required this.onResetTapUp,
    required this.onResetTapCancel,
  });

  /// Minimum width in logical pixels for the three-column layout.
  static const double wideBreakpoint = 1200;

  final Map<String, int> counts;
  final bool isResetHolding;
  final double resetProgress;
  final void Function(String id) onIncrement;
  final void Function(String id) onDecrement;
  final void Function(String id, int value) onSetCount;
  final VoidCallback onResetTapDown;
  final VoidCallback onResetTapUp;
  final VoidCallback onResetTapCancel;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= wideBreakpoint;
    return isWide ? _buildWideLayout() : _buildNarrowLayout();
  }

  Widget _buildNarrowLayout() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
      itemCount: cashCategories.length + 1,
      itemBuilder: (context, index) {
        if (index == cashCategories.length) {
          return _buildResetButton();
        }
        return _buildCategorySection(cashCategories[index]);
      },
    );
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cashCategories.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 6,
                      right: i == cashCategories.length - 1 ? 0 : 6,
                    ),
                    child: _buildCategorySection(cashCategories[i]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildCategorySection(CashCategory category) {
    return CategorySection(
      category: category,
      counts: counts,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
      onSetCount: onSetCount,
    );
  }

  Widget _buildResetButton() {
    return ResetButton(
      isHolding: isResetHolding,
      progress: resetProgress,
      onTapDown: onResetTapDown,
      onTapUp: onResetTapUp,
      onTapCancel: onResetTapCancel,
    );
  }
}
