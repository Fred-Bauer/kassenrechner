import 'dart:js_interop';
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'clipboard_copy_result.dart';

@JS('navigator.clipboard.writeText')
external JSPromise<JSAny?> _clipboardWriteText(JSString text);

void _logClipboardFailure(String stage, Object error) {
  if (!kDebugMode) {
    return;
  }
  final message = error.toString();
  final looksLikeActivationIssue =
      message.contains('NotAllowedError') ||
      message.contains('user activation') ||
      message.contains('gesture');
  final reason = looksLikeActivationIssue
      ? 'likely iOS/Safari user-activation restriction'
      : 'unknown browser restriction';
  debugPrint('Clipboard copy failed at $stage ($reason): $message');
}

Future<ClipboardCopyResult> _shareTextFallback(String text) async {
  if (!js_util.hasProperty(web.window.navigator, 'share')) {
    return ClipboardCopyResult.failed;
  }

  try {
    final shareData = js_util.jsify(<String, String>{'text': text});
    await js_util.promiseToFuture<Object?>(
      js_util.callMethod<Object?>(web.window.navigator, 'share', [shareData]),
    );
    return ClipboardCopyResult.shared;
  } catch (error) {
    _logClipboardFailure('navigator.share', error);
    return ClipboardCopyResult.failed;
  }
}

Future<ClipboardCopyResult> copyTextToClipboard(String text) async {
  // Preferred path: navigator.clipboard.writeText() direkt via js_interop,
  // um den iOS-Safari-Gesture-Context nicht durch Flutter-MethodChannel-
  // Microtasks zu verlieren.
  try {
    await _clipboardWriteText(text.toJS).toDart;
    return ClipboardCopyResult.copied;
  } catch (error) {
    _logClipboardFailure('navigator.clipboard.writeText', error);
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
    if (copied) {
      return ClipboardCopyResult.copied;
    }
    return _shareTextFallback(text);
  } catch (error) {
    _logClipboardFailure('document.execCommand(copy)', error);
    return _shareTextFallback(text);
  }
}
