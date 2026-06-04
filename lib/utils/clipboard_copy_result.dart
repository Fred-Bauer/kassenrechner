/// Outcome of trying to transfer receipt text to a shareable channel.
enum ClipboardCopyResult {
  /// Text was written to the system clipboard.
  copied,

  /// Clipboard copy failed, but the platform share sheet was opened.
  shared,

  /// Neither clipboard copy nor sharing succeeded.
  failed,
}