import 'dart:convert';
import 'dart:io';

import 'exceptions/converter_exception.dart';
import 'logger.dart';

/// Raw result of executing the ffmpeg process, before it is interpreted
/// as success/failure by [HlsConverter].
class FFmpegExecutionResult {
  /// Exit code returned by the process.
  final int exitCode;

  /// Full standard error output captured during execution, used for
  /// diagnostics when [exitCode] is non-zero.
  final String stderrOutput;

  const FFmpegExecutionResult({
    required this.exitCode,
    required this.stderrOutput,
  });
}

/// Responsible only for starting the ffmpeg process, streaming its
/// stdout/stderr, waiting for completion, and returning the outcome.
///
/// This class deliberately knows nothing about playlists, validation,
/// or command construction (Single Responsibility Principle).
abstract class FFmpegService {
  Future<FFmpegExecutionResult> run({
    required String executablePath,
    required List<String> arguments,
  });
}

/// [FFmpegService] implementation backed by `dart:io`'s [Process.start],
/// which streams output incrementally instead of buffering it all in
/// memory the way [Process.run] would.
class ProcessFFmpegService implements FFmpegService {
  final Logger _logger;

  const ProcessFFmpegService(this._logger);

  @override
  Future<FFmpegExecutionResult> run({
    required String executablePath,
    required List<String> arguments,
  }) async {
    late final Process process;
    try {
      process = await Process.start(
        executablePath,
        arguments,
      );
    } on ProcessException catch (e) {
      throw FFmpegNotFoundException(e.message);
    }

    final stderrBuffer = StringBuffer();

    final stdoutSubscription = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (line.trim().isNotEmpty) {
        _logger.progress(line);
      }
    });

    // ffmpeg writes both its progress output and its diagnostics to
    // stderr by design, so we both log it live and retain it for
    // error reporting if the process ultimately fails.
    final stderrSubscription = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (line.trim().isNotEmpty) {
        stderrBuffer.writeln(line);
        _logger.progress(line);
      }
    });

    final exitCode = await process.exitCode;

    await stdoutSubscription.cancel();
    await stderrSubscription.cancel();

    return FFmpegExecutionResult(
      exitCode: exitCode,
      stderrOutput: stderrBuffer.toString(),
    );
  }
}
