import 'clipboard_copy_result.dart';
import 'clipboard_helper_stub.dart'
    if (dart.library.html) 'clipboard_helper_web.dart' as impl;

/// Tries to copy text and applies platform-specific fallbacks where available.
Future<ClipboardCopyResult> copyTextToClipboard(String text) {
  return impl.copyTextToClipboard(text);
}
