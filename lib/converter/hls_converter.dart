import 'command_builder.dart';
import 'constants.dart';
import 'exceptions/converter_exception.dart';
import 'ffmpeg_service.dart';
import 'logger.dart';
import 'models/conversion_result.dart';
import 'validator.dart';

/// Converts an offline HLS folder (an `.m3u8` playlist plus its `.ts`
/// segments) into a single MP4 file using the system-installed
/// `ffmpeg` executable.
///
/// This is the only class most callers ever need:
///
/// ```dart
/// final converter = HlsConverter();
/// final result = await converter.convert(
///   inputFolder: 'D:\\Videos\\Episode01',
///   outputFile: 'D:\\Videos\\Episode01.mp4',
/// );
/// ```
///
/// All collaborators ([Validator], [CommandBuilder], [FFmpegService],
/// [Logger]) are injected through the constructor and default to their
/// production implementations, so [HlsConverter] itself contains no
/// business logic of its own beyond orchestration (SOLID: Dependency
/// Inversion / Single Responsibility).
class HlsConverter {
  final Logger _logger;
  final Validator _validator;
  final CommandBuilder _commandBuilder;
  final FFmpegService _ffmpegService;
  final String _ffmpegExecutable;

  /// Creates a converter.
  ///
  /// All parameters are optional and default to production-ready
  /// implementations. Supply alternatives (e.g. mocks) for testing.
  HlsConverter({
    Logger? logger,
    Validator? validator,
    CommandBuilder? commandBuilder,
    FFmpegService? ffmpegService,
    this._ffmpegExecutable = ConverterConstants.defaultFFmpegExecutable,
  })  : _logger = logger ?? const ConsoleLogger(),
        _validator = validator ?? Validator(logger ?? const ConsoleLogger()),
        _commandBuilder = commandBuilder ?? const FFmpegCommandBuilder(),
        _ffmpegService =
            ffmpegService ?? ProcessFFmpegService(logger ?? const ConsoleLogger());

  /// Runs the full conversion pipeline: validation, playlist detection,
  /// ffmpeg command construction, process execution, and result
  /// reporting.
  ///
  /// Throws a [ConverterException] subtype for every failure mode
  /// (missing folder, missing playlist, missing ffmpeg, invalid output
  /// path, unwritable output directory, or a non-zero ffmpeg exit
  /// code). Never throws a bare [Exception].
  Future<ConversionResult> convert({
    required String inputFolder,
    required String outputFile,
  }) async {
    final stopwatch = Stopwatch()..start();

    _logger.info('Checking folder...');
    await _validator.validateInputFolder(inputFolder);

    final playlists = await _validator.resolvePlaylists(inputFolder);
    final playlistNames = playlists.map((f) => f.uri.pathSegments.last).join(', ');
    _logger.info('Playlist candidates found (${playlists.length}): $playlistNames');

    _logger.info('Checking ffmpeg availability...');
    await _validator.validateFFmpegAvailable(_ffmpegExecutable);

    _logger.info('Checking output path...');
    await _validator.validateAndPrepareOutput(outputFile);

    FFmpegProcessException? lastProcessException;

    for (var i = 0; i < playlists.length; i++) {
      final playlist = playlists[i];
      final fileName = playlist.uri.pathSegments.last;

      _logger.info(
        'Attempting conversion using playlist (${i + 1}/${playlists.length}):\n${playlist.path}',
      );

      final arguments = _commandBuilder.build(
        inputPath: playlist.path,
        outputPath: outputFile,
      );

      final executionResult = await _ffmpegService.run(
        executablePath: _ffmpegExecutable,
        arguments: arguments,
      );

      if (executionResult.exitCode == 0) {
        stopwatch.stop();
        _logger.success('Video saved:\n$outputFile');
        return ConversionResult(
          success: true,
          outputPath: outputFile,
          duration: stopwatch.elapsed,
          exitCode: executionResult.exitCode,
        );
      }

      lastProcessException = FFmpegProcessException(
        executionResult.exitCode,
        executionResult.stderrOutput,
      );

      if (i < playlists.length - 1) {
        _logger.warning(
          'Conversion failed using playlist "$fileName" (exit code ${executionResult.exitCode}). '
          'Retrying with next playlist candidate...',
        );
      }
    }

    stopwatch.stop();

    throw lastProcessException ??
        FFmpegProcessException(-1, 'All playlist candidates failed to convert.');
  }
}

