import 'dart:io';

import 'package:hls_to_mp4/converter/exceptions/converter_exception.dart';
import 'package:hls_to_mp4/converter/hls_converter.dart';
import 'package:hls_to_mp4/converter/logger.dart';

/// Exit codes returned by this console application.
abstract class _ExitCode {
  static const int success = 0;
  static const int usageError = 64;
  static const int conversionError = 1;
}

const String _usage =
    'Usage:\n\n'
    'dart run bin/main.dart <input_folder> <output_file>\n\n'
    'Example:\n'
    '  dart run bin/main.dart "D:\\Videos\\Episode01" "D:\\Videos\\Episode01.mp4"';

Future<void> main(List<String> arguments) async {
  final Logger logger = const ConsoleLogger();

  if (arguments.length != 2) {
    stdout.writeln(_usage);
    exit(_ExitCode.usageError);
  }

  final String inputFolder = arguments[0];
  final String outputFile = arguments[1];

  final ffmpegPath = File('tools/ffmpeg.exe').absolute.path;

  final converter = HlsConverter(logger: logger, ffmpegExecutable: ffmpegPath);

  try {
    final result = await converter.convert(inputFolder: inputFolder, outputFile: outputFile);

    logger.info(
      'Done in ${result.duration.inSeconds}s '
      '(exit code ${result.exitCode}).',
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
