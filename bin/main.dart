import 'dart:io';

import 'package:hls_to_mp4/hls_to_mp4.dart';

/// Exit codes returned by this console application.
abstract class _ExitCode {
  static const int success = 0;
  static const int usageError = 64;
  static const int conversionError = 1;
}

const String _usage = '''
Usage:
  dart run bin/main.dart <input_path> <output_path>

Supported Conversions (Auto-detected):
  1. HLS -> MP4:
     dart run bin/main.dart "D:\\Videos\\Episode01" "D:\\Videos\\Episode01.mp4"

  2. MP4 -> HLS:
     dart run bin/main.dart "D:\\Videos\\Episode01.mp4" "D:\\Videos\\Episode01_hls"
''';

Future<void> main(List<String> arguments) async {
  final Logger logger = const ConsoleLogger();

  if (arguments.length != 2) {
    stdout.writeln(_usage);
    exit(_ExitCode.usageError);
  }

  final String inputPath = arguments[0];
  final String outputPath = arguments[1];

  final localFFmpeg = File('tools/ffmpeg.exe');
  final ffmpegPath = localFFmpeg.existsSync()
      ? localFFmpeg.absolute.path
      : ConverterConstants.defaultFFmpegExecutable;

  final bool isMp4Input = inputPath.toLowerCase().endsWith(ConverterConstants.expectedMp4Extension) ||
      (await File(inputPath).exists());

  try {
    final ConversionResult result;

    if (isMp4Input) {
      logger.info('Mode: MP4 to HLS conversion');
      final converter = Mp4ToHlsConverter(logger: logger, ffmpegExecutable: ffmpegPath);
      result = await converter.convert(
        inputFile: inputPath,
        outputDirectoryOrPlaylist: outputPath,
      );
    } else {
      logger.info('Mode: HLS to MP4 conversion');
      final converter = HlsConverter(logger: logger, ffmpegExecutable: ffmpegPath);
      result = await converter.convert(
        inputFolder: inputPath,
        outputFile: outputPath,
      );
    }

    logger.info(
      'Done in ${result.duration.inSeconds}s (exit code ${result.exitCode}).',
    );
    exit(_ExitCode.success);
  } on ConverterException catch (e) {
    logger.error(e.message);
    exit(_ExitCode.conversionError);
  } catch (e) {
    logger.error('Unexpected error: $e');
    exit(_ExitCode.conversionError);
  }
}
