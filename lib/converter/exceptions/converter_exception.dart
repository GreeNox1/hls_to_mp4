/// Base type for every exception raised by this package.
///
/// All errors surfaced by the converter are instances of a subclass of
/// [ConverterException] so callers can catch a single type and still
/// inspect [message] for a human-readable explanation. No part of this
/// package throws a bare [Exception] or [Error].
abstract class ConverterException implements Exception {
  /// Human-readable explanation of what went wrong.
  final String message;

  const ConverterException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the input folder supplied to the converter does not exist
/// on disk.
class InputFolderNotFoundException extends ConverterException {
  InputFolderNotFoundException(String path)
      : super('Input folder not found: "$path".');
}

/// Thrown when neither `index.m3u8` nor `index_rel.m3u8` can be found
/// inside the input folder.
class PlaylistNotFoundException extends ConverterException {
  PlaylistNotFoundException(String folder)
      : super(
          'No playlist file found in "$folder". '
          'Expected "index.m3u8" or "index_rel.m3u8".',
        );
}

/// Thrown when the `ffmpeg` executable cannot be located or executed on
/// the host system.
class FFmpegNotFoundException extends ConverterException {
  FFmpegNotFoundException([String? details])
      : super(
          'ffmpeg executable was not found or could not be started. '
          'Please install ffmpeg and ensure it is available on PATH.'
          '${details != null ? '\nDetails: $details' : ''}',
        );
}

/// Thrown when the output directory cannot be created, is not writable,
/// or otherwise fails validation.
class OutputDirectoryException extends ConverterException {
  OutputDirectoryException(String path, String reason)
      : super('Output directory error for "$path": $reason');
}

/// Thrown when the supplied output file path is structurally invalid
/// (e.g. empty, or missing a valid file name).
class InvalidOutputPathException extends ConverterException {
  InvalidOutputPathException(String path)
      : super('Invalid output file path: "$path".');
}

/// Thrown when the underlying ffmpeg process exits with a non-zero exit
/// code. Carries the [exitCode] and captured standard error output so
/// callers can present a meaningful diagnostic.
class FFmpegProcessException extends ConverterException {
  final int exitCode;
  final String stderrOutput;

  FFmpegProcessException(this.exitCode, this.stderrOutput)
      : super(
          'ffmpeg process failed with exit code $exitCode.'
          '${stderrOutput.trim().isNotEmpty ? '\n$stderrOutput' : ''}',
        );
}

/// Thrown when the process does not have permission to read the input
/// folder or write to the output location.
class PermissionDeniedException extends ConverterException {
  PermissionDeniedException(String path)
      : super('Permission denied while accessing: "$path".');
}
