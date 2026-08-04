/// Outcome of a single HLS-to-MP4 conversion run.
///
/// Returned by [HlsConverter.convert] on success. Instances are
/// immutable value objects.
class ConversionResult {
  /// Whether the conversion completed successfully.
  final bool success;

  /// Absolute or relative path of the produced MP4 file.
  final String outputPath;

  /// Wall-clock time the conversion took, from validation start to
  /// ffmpeg process completion.
  final Duration duration;

  /// Exit code returned by the ffmpeg process (0 on success).
  final int exitCode;

  const ConversionResult({
    required this.success,
    required this.outputPath,
    required this.duration,
    required this.exitCode,
  });

  @override
  String toString() =>
      'ConversionResult(success: $success, outputPath: $outputPath, '
      'duration: $duration, exitCode: $exitCode)';
}
