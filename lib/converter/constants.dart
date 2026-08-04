/// Centralized constants for the HLS-to-MP4 converter.
///
/// Keeping every literal value in one place avoids "magic strings"
/// scattered across the codebase and makes future changes (e.g. a new
/// playlist filename convention) a one-line edit.
class ConverterConstants {
  const ConverterConstants._();

  /// Playlist file names, in priority order.
  ///
  /// [primaryPlaylistName] is preferred over [fallbackPlaylistName] when
  /// both are present in the input folder.
  static const String primaryPlaylistName = 'index.m3u8';
  static const String fallbackPlaylistName = 'index_rel.m3u8';

  static const List<String> playlistCandidates = <String>[
    primaryPlaylistName,
    fallbackPlaylistName,
  ];

  /// Default name of the ffmpeg executable as resolved from PATH.
  static const String defaultFFmpegExecutable = 'ffmpeg';

  /// Expected output file extensions.
  static const String expectedMp4Extension = '.mp4';
  static const String expectedM3u8Extension = '.m3u8';

  /// ffmpeg CLI flags.
  static const String flagInput = '-i';
  static const String flagCodec = '-c';
  static const String flagOverwrite = '-y';
  static const String flagVersion = '-version';
  static const String flagFormat = '-f';
  static const String flagStartNumber = '-start_number';
  static const String flagHlsTime = '-hls_time';
  static const String flagHlsListSize = '-hls_list_size';

  static const String formatHls = 'hls';
  static const String codecCopy = 'copy';
  static const String defaultHlsSegmentTimeSeconds = '10';
  static const String defaultHlsStartNumber = '0';
  static const String defaultHlsListSize = '0';
}

