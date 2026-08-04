import 'command_builder.dart';
import 'constants.dart';
import 'exceptions/converter_exception.dart';
import 'ffmpeg_service.dart';
import 'logger.dart';
import 'models/conversion_result.dart';
import 'validator.dart';

/// Converts a single MP4 video file into an HLS playlist (`.m3u8`) and `.ts`
/// segment files using the system-installed `ffmpeg` executable.
///
/// Example:
/// ```dart
/// final converter = Mp4ToHlsConverter();
/// final result = await converter.convert(
///   inputFile: 'D:\\Videos\\Episode01.mp4',
///   outputDirectoryOrPlaylist: 'D:\\Videos\\Episode01_hls',
/// );
/// ```
class Mp4ToHlsConverter {
  final Logger _logger;
  final Validator _validator;
  final CommandBuilder _commandBuilder;
  final FFmpegService _ffmpegService;
  final String _ffmpegExecutable;

  /// Creates an MP4-to-HLS converter.
  Mp4ToHlsConverter({
    Logger? logger,
    Validator? validator,
    CommandBuilder? commandBuilder,
    FFmpegService? ffmpegService,
    this._ffmpegExecutable = ConverterConstants.defaultFFmpegExecutable,
  })  : _logger = logger ?? const ConsoleLogger(),
        _validator = validator ?? Validator(logger ?? const ConsoleLogger()),
        _commandBuilder = commandBuilder ?? const Mp4ToHlsCommandBuilder(),
        _ffmpegService =
            ffmpegService ?? ProcessFFmpegService(logger ?? const ConsoleLogger());

  /// Runs the full conversion pipeline: input validation, output directory
  /// preparation, ffmpeg command construction, process execution, and result reporting.
  Future<ConversionResult> convert({
    required String inputFile,
    required String outputDirectoryOrPlaylist,
  }) async {
    final stopwatch = Stopwatch()..start();

    _logger.info('Checking input MP4 file...');
    await _validator.validateInputFile(inputFile);

    _logger.info('Checking ffmpeg availability...');
    await _validator.validateFFmpegAvailable(_ffmpegExecutable);

    _logger.info('Preparing HLS output directory...');
    final resolvedPlaylistPath = await _validator.validateAndPrepareHlsOutput(outputDirectoryOrPlaylist);

    final arguments = _commandBuilder.build(
      inputPath: inputFile,
      outputPath: resolvedPlaylistPath,
    );

    _logger.info('Starting MP4 to HLS conversion...');
    final executionResult = await _ffmpegService.run(
      executablePath: _ffmpegExecutable,
      arguments: arguments,
    );

    stopwatch.stop();

    if (executionResult.exitCode != 0) {
      throw FFmpegProcessException(
        executionResult.exitCode,
        executionResult.stderrOutput,
      );
    }

    _logger.success('HLS stream created successfully:\n$resolvedPlaylistPath');

    return ConversionResult(
      success: true,
      outputPath: resolvedPlaylistPath,
      duration: stopwatch.elapsed,
      exitCode: executionResult.exitCode,
    );
  }
}
