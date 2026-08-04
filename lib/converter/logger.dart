/// Abstraction over log output.
///
/// Depending on [Logger] rather than concrete console I/O keeps
/// [HlsConverter] and its collaborators testable and decoupled from any
/// particular presentation concern (SOLID: Dependency Inversion).
abstract class Logger {
  /// General informational message about the current step.
  void info(String message);

  /// Message that indicates a successful completion.
  void success(String message);

  /// Message that indicates a recoverable or non-fatal problem.
  void warning(String message);

  /// Message that indicates a failure.
  void error(String message);

  /// A single line of live ffmpeg output (progress/streaming).
  void progress(String message);
}

/// Pretty-prints log messages to stdout with ANSI colors when the
/// message represents a tag ([INFO], [SUCCESS], etc.).
///
/// Colors degrade gracefully: terminals that do not understand ANSI
/// escape codes simply display the raw escape sequence, which is a
/// standard, accepted trade-off for console applications.
class ConsoleLogger implements Logger {
  static const String _reset = '\x1B[0m';
  static const String _cyan = '\x1B[36m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _magenta = '\x1B[35m';

  static const String _tagInfo = '[INFO]';
  static const String _tagSuccess = '[SUCCESS]';
  static const String _tagWarning = '[WARNING]';
  static const String _tagError = '[ERROR]';
  static const String _tagProgress = '[PROGRESS]';

  const ConsoleLogger();

  @override
  void info(String message) => _log(_tagInfo, _cyan, message);

  @override
  void success(String message) => _log(_tagSuccess, _green, message);

  @override
  void warning(String message) => _log(_tagWarning, _yellow, message);

  @override
  void error(String message) => _log(_tagError, _red, message);

  @override
  void progress(String message) => _log(_tagProgress, _magenta, message);

  void _log(String tag, String color, String message) {
    // ignore: avoid_print
    print('$color$tag$_reset\n$message\n');
  }
}
