/// Result of attempting to place text into a shareable channel.
enum ClipboardCopyResult {
  /// Text was successfully copied into the system clipboard.
  copied,

  /// Clipboard copy failed, but the platform share sheet was opened.
  shared,

  /// Neither clipboard copy nor sharing was possible.
  failed,
}
