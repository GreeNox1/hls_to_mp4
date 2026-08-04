import 'constants.dart';

/// Builds the list of CLI arguments to pass to the `ffmpeg` executable.
///
/// Isolating command construction behind this interface means the
/// converter never hardcodes command strings, and alternative
/// strategies (e.g. re-encoding instead of stream-copying) can be
/// introduced by adding a new implementation, without touching
/// [HlsConverter] (Open/Closed Principle).
abstract class CommandBuilder {
  /// Returns the ordered list of arguments ffmpeg should be invoked with.
  List<String> build({
    required String inputPath,
    required String outputPath,
  });
}

/// [CommandBuilder] that performs a fast, lossless remux of the
/// HLS stream into a single MP4 container via stream copy (`-c copy`).
class HlsToMp4CommandBuilder implements CommandBuilder {
  const HlsToMp4CommandBuilder();

  @override
  List<String> build({
    required String inputPath,
    required String outputPath,
  }) {
    return <String>[
      ConverterConstants.flagInput,
      inputPath,
      ConverterConstants.flagCodec,
      ConverterConstants.codecCopy,
      ConverterConstants.flagOverwrite,
      outputPath,
    ];
  }
}

/// Alias for [HlsToMp4CommandBuilder] for backward compatibility.
typedef FFmpegCommandBuilder = HlsToMp4CommandBuilder;

/// [CommandBuilder] that splits an MP4 video into an HLS playlist (.m3u8)
/// and segment files (.ts).
class Mp4ToHlsCommandBuilder implements CommandBuilder {
  final int segmentTimeSeconds;

  const Mp4ToHlsCommandBuilder({
    this.segmentTimeSeconds = 10,
  });

  @override
  List<String> build({
    required String inputPath,
    required String outputPath,
  }) {
    return <String>[
      ConverterConstants.flagInput,
      inputPath,
      ConverterConstants.flagCodec,
      ConverterConstants.codecCopy,
      ConverterConstants.flagStartNumber,
      ConverterConstants.defaultHlsStartNumber,
      ConverterConstants.flagHlsTime,
      segmentTimeSeconds.toString(),
      ConverterConstants.flagHlsListSize,
      ConverterConstants.defaultHlsListSize,
      ConverterConstants.flagFormat,
      ConverterConstants.formatHls,
      ConverterConstants.flagOverwrite,
      outputPath,
    ];
  }
}

