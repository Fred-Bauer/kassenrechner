import 'package:flutter/material.dart';

import '../data/cash_categories.dart';
import '../notifiers/cash_counter_notifier.dart';
import '../utils/clipboard_helper.dart';
import '../utils/easter_egg_controller.dart';
import '../utils/receipt_formatter.dart';
import '../widgets/cash_counter_layout.dart';
import '../widgets/love_confetti_overlay.dart';
import '../widgets/total_header.dart';

/// Main counting screen. State is delegated to [CashCounterNotifier] and
/// [EasterEggController]; this widget only owns UI callbacks that need context.
class CashCounterHomePage extends StatefulWidget {
  const CashCounterHomePage({super.key});

  @override
  State<CashCounterHomePage> createState() => _CashCounterHomePageState();
}

class _CashCounterHomePageState extends State<CashCounterHomePage> {
  late final CashCounterNotifier _notifier;
  late final EasterEggController _easterEgg;
  bool _deductMode = false;

  @override
  void initState() {
    super.initState();
    _notifier = CashCounterNotifier()..onResetComplete = _onResetComplete;
    _easterEgg = EasterEggController();
  }

  @override
  void dispose() {
    _notifier.dispose();
    _easterEgg.dispose();
    super.dispose();
  }

  void _toggleDeductMode() => setState(() => _deductMode = !_deductMode);

  void _onResetComplete() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rechnung wurde zurückgesetzt.')),
    );
  }

  Future<void> _copyReceiptToClipboard() async {
    final receipt = buildReceiptText(
      categories: cashCategories,
      counts: _notifier.counts,
      totalValue: _notifier.totalValue,
    );

    final copied = await copyTextToClipboard(receipt);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          copied
              ? 'Rechnung wurde in die Zwischenablage kopiert.'
              : 'Kopieren nicht erlaubt. Bitte Browserberechtigung prüfen.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ListenableBuilder(
                  listenable: Listenable.merge([_notifier, _easterEgg]),
                  builder: (context, _) => TotalHeader(
                    totalValue: _notifier.totalValue,
                    onTap: _toggleDeductMode,
                    onTapDown: _easterEgg.handleTap,
                    onLongPress: _copyReceiptToClipboard,
                    centerMessage:
                        _easterEgg.showEasterEgg ? EasterEggController.message : null,
                    subtractAmount: _deductMode ? 1500.0 : null,
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _notifier,
                    builder: (context, _) => CashCounterLayout(
                      counts: _notifier.counts,
                      isResetHolding: _notifier.isResetHolding,
                      resetProgress: _notifier.resetProgress,
                      onIncrement: (id) => _notifier.changeCount(id, 1),
                      onDecrement: (id) => _notifier.changeCount(id, -1),
                      onSetCount: _notifier.setCount,
                      onResetTapDown: _notifier.startResetHold,
                      onResetTapUp: _notifier.cancelResetHold,
                      onResetTapCancel: _notifier.cancelResetHold,
                    ),
                  ),
                ),
              ],
            ),
            LoveConfettiOverlay(
              controller: _easterEgg.confettiController,
            ),
          ],
        ),
      ),
    );
  }
}