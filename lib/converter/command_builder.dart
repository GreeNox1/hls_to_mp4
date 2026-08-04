import 'constants.dart';

/// Builds the list of CLI arguments to pass to the `ffmpeg` executable.
///
/// Isolating command construction behind this interface means the
/// converter never hardcodes command strings, and alternative
/// strategies (e.g. re-encoding instead of stream-copying) can be
/// introduced by adding a new implementation, without touching
/// [HlsConverter] (Open/Closed Principle).
abstract class CommandBuilder {
  /// Returns the ordered list of arguments ffmpeg should be invoked
  /// with, e.g. `['-i', playlistPath, '-c', 'copy', '-y', outputPath]`.
  List<String> build({
    required String playlistPath,
    required String outputPath,
  });
}

/// Default [CommandBuilder] that performs a fast, lossless remux of the
/// HLS stream into a single MP4 container via stream copy (`-c copy`).
class FFmpegCommandBuilder implements CommandBuilder {
  const FFmpegCommandBuilder();

  @override
  List<String> build({
    required String playlistPath,
    required String outputPath,
  }) {
    return <String>[
      ConverterConstants.flagInput,
      playlistPath,
      ConverterConstants.flagCodec,
      ConverterConstants.codecCopy,
      ConverterConstants.flagOverwrite,
      outputPath,
    ];
  }
}
