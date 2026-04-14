import 'package:flutter/services.dart';

/// Non-web clipboard fallback that uses Flutter's built-in [Clipboard.setData].
Future<bool> copyTextToClipboard(String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  } catch (_) {
    return false;
  }
}
