import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CountSetDialog extends StatefulWidget {
  const CountSetDialog({
    super.key,
    required this.title,
    required this.initialCount,
  });

  final String title;
  final int initialCount;

  @override
  State<CountSetDialog> createState() => _CountSetDialogState();
}

class _CountSetDialogState extends State<CountSetDialog> {
  late final TextEditingController _controller;
  late final FocusNode _inputFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialCount}');
    _inputFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _inputFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed != null && parsed >= 0) {
      Navigator.of(context).pop(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DialogEnterSubmit(
      onSubmit: _submit,
      child: AlertDialog(
        title: Text(widget.title),
        content: TextField(
          controller: _controller,
          focusNode: _inputFocusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [DigitsOnlyFormatter()],
          decoration: const InputDecoration(
            labelText: 'Anzahl',
            border: OutlineInputBorder(),
          ),
          onEditingComplete: _submit,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(onPressed: _submit, child: const Text('OK')),
        ],
      ),
    );
  }
}

class CoinSetDialog extends StatefulWidget {
  const CoinSetDialog({
    super.key,
    required this.title,
    required this.coinValue,
    required this.initialCount,
  });

  final String title;
  final double coinValue;
  final int initialCount;

  @override
  State<CoinSetDialog> createState() => _CoinSetDialogState();
}

class _CoinSetDialogState extends State<CoinSetDialog> {
  late final TextEditingController _sumController;
  late final TextEditingController _countController;
  late final FocusNode _sumFocusNode;
  late final FocusNode _countFocusNode;

  @override
  void initState() {
    super.initState();
    _sumController = TextEditingController();
    _countController = TextEditingController(
      text: widget.initialCount > 0 ? '${widget.initialCount}' : '',
    );
    _sumFocusNode = FocusNode();
    _countFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _sumFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _sumController.dispose();
    _countController.dispose();
    _sumFocusNode.dispose();
    _countFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final sumText = _sumController.text.trim();
    final countText = _countController.text.trim();

    int parsed = 0;

    if (sumText.isNotEmpty) {
      final normalized = sumText.replaceAll(',', '.');
      final sum = double.tryParse(normalized);
      if (sum != null && sum >= 0) {
        parsed = (sum / widget.coinValue).round();
      } else {
        return;
      }
    } else if (countText.isNotEmpty) {
      parsed = int.tryParse(countText) ?? 0;
      if (parsed < 0) return;
    }

    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return _DialogEnterSubmit(
      onSubmit: _submit,
      child: AlertDialog(
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _sumController,
              focusNode: _sumFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: [DecimalInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Summe (€)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() => _countController.clear());
                }
              },
              onEditingComplete: _submit,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countController,
              focusNode: _countFocusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [DigitsOnlyFormatter()],
              decoration: const InputDecoration(
                labelText: 'Anzahl',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() => _sumController.clear());
                }
              },
              onEditingComplete: _submit,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(onPressed: _submit, child: const Text('OK')),
        ],
      ),
    );
  }
}

/// Captures Enter/NumpadEnter on dialog level and forwards it to submit.
class _DialogEnterSubmit extends StatelessWidget {
  const _DialogEnterSubmit({
    required this.onSubmit,
    required this.child,
  });

  final VoidCallback onSubmit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onSubmit();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

/// Allows only digits, dot, and comma.
class DecimalInputFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r'^[0-9.,]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _allowed.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

/// Allows only digits.
class DigitsOnlyFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r'^[0-9]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _allowed.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
