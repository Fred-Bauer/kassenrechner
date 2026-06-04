import 'package:flutter/services.dart';

import 'clipboard_copy_result.dart';

/// Non-web clipboard fallback that uses Flutter's built-in [Clipboard.setData].
Future<ClipboardCopyResult> copyTextToClipboard(String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    return ClipboardCopyResult.copied;
  } catch (_) {
    return ClipboardCopyResult.failed;
  }
}
