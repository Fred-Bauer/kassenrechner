import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('navigator.clipboard.writeText')
external JSPromise<JSAny?> _clipboardWriteText(JSString text);

Future<bool> copyTextToClipboard(String text) async {
  // Preferred path: navigator.clipboard.writeText() direkt via js_interop,
  // um den iOS-Safari-Gesture-Context nicht durch Flutter-MethodChannel-
  // Microtasks zu verlieren.
  try {
    await _clipboardWriteText(text.toJS).toDart;
    return true;
  } catch (_) {
    // Fall through to legacy selection-based copy for iOS Safari.
  }

  try {
    final textarea =
        web.document.createElement('textarea') as web.HTMLTextAreaElement
          ..value = text
          ..style.position = 'fixed'
          ..style.left = '-10000px'
          ..style.top = '0'
          ..style.opacity = '0'
          ..style.fontSize = '16px' // Verhindert Zoom auf iOS
          ..readOnly = true;

    web.document.body?.append(textarea);
    textarea.focus();
    // setSelectionRange ist auf iOS Safari erforderlich, da select() allein
    // keinen Text selektiert.
    textarea.setSelectionRange(0, text.length);

    final copied = web.document.execCommand('copy');
    textarea.remove();
    return copied;
  } catch (_) {
    return false;
  }
}
