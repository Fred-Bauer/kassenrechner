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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialCount}');
  }

  @override
  void dispose() {
    _controller.dispose();
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
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [DigitsOnlyFormatter()],
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Anzahl',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(onPressed: _submit, child: const Text('OK')),
      ],
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

  @override
  void initState() {
    super.initState();
    _sumController = TextEditingController();
    _countController = TextEditingController(
      text: widget.initialCount > 0 ? '${widget.initialCount}' : '',
    );
  }

  @override
  void dispose() {
    _sumController.dispose();
    _countController.dispose();
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
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _sumController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [DecimalInputFormatter()],
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Summe (€)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) setState(() => _countController.clear());
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            inputFormatters: [DigitsOnlyFormatter()],
            decoration: const InputDecoration(
              labelText: 'Anzahl',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) setState(() => _sumController.clear());
            },
            onSubmitted: (_) => _submit(),
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
