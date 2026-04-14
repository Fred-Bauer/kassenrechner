import 'dart:html' as html;

import 'package:flutter/services.dart';

Future<bool> copyTextToClipboard(String text) async {
  // Preferred path: async clipboard API via Flutter wrapper.
  try {
    await Clipboard.setData(ClipboardData(text: text));
    return true;
  } catch (_) {
    // Fall through to legacy selection-based copy for iOS Safari.
  }

  try {
    final textarea = html.TextAreaElement()
      ..value = text
      ..style.position = 'fixed'
      ..style.left = '-10000px'
      ..style.top = '0'
      ..style.opacity = '0'
      ..setAttribute('readonly', 'true');

    final body = html.document.body;
    if (body == null) {
      return false;
    }

    body.append(textarea);
    textarea.focus();
    textarea.select();

    final copied = html.document.execCommand('copy');
    textarea.remove();
    return copied;
  } catch (_) {
    return false;
  }
}
