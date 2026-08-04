import 'dart:io';

import 'constants.dart';
import 'exceptions/converter_exception.dart';
import 'logger.dart';

/// Performs every pre-flight check required before a conversion can
/// safely start.
///
/// A single class owns all validation logic (Single Responsibility),
/// while [HlsConverter] simply calls into it and reacts to the typed
/// exceptions it throws.
class Validator {
  final Logger _logger;

  const Validator(this._logger);

  /// Verifies that [inputFolder] exists on disk.
  ///
  /// Throws [InputFolderNotFoundException] if it does not exist, or
  /// [PermissionDeniedException] if it exists but cannot be accessed.
  Future<void> validateInputFolder(String inputFolder) async {
    final directory = Directory(inputFolder);

    late final bool exists;
    try {
      exists = await directory.exists();
    } on FileSystemException {
      throw PermissionDeniedException(inputFolder);
    }

    if (!exists) {
      throw InputFolderNotFoundException(inputFolder);
    }

    try {
      // Force a listing to surface permission problems early rather
      // than deep inside ffmpeg's own (harder to parse) error output.
      await directory.list().toList();
    } on FileSystemException {
      throw PermissionDeniedException(inputFolder);
    }
  }

  /// Verifies that [inputFile] exists on disk as a file.
  ///
  /// Throws [InputFileNotFoundException] if it does not exist, or
  /// [PermissionDeniedException] if it exists but cannot be accessed.
  Future<void> validateInputFile(String inputFile) async {
    final file = File(inputFile);

    late final bool exists;
    try {
      exists = await file.exists();
    } on FileSystemException {
      throw PermissionDeniedException(inputFile);
    }

    if (!exists) {
      throw InputFileNotFoundException(inputFile);
    }
  }


  /// Resolves all available playlist files in priority order.
  ///
  /// Looks for [ConverterConstants.playlistCandidates] first. If none are found,
  /// scans [inputFolder] for any `.m3u8` files. Throws [PlaylistNotFoundException]
  /// if no playlist candidate files exist.
  Future<List<File>> resolvePlaylists(String inputFolder) async {
    final List<File> candidates = [];

    for (final candidateName in ConverterConstants.playlistCandidates) {
      final candidate = File(_joinPath(inputFolder, candidateName));
      if (await candidate.exists()) {
        candidates.add(candidate);
      }
    }

    if (candidates.isEmpty) {
      final directory = Directory(inputFolder);
      try {
        final entries = await directory.list().toList();
        for (final entry in entries) {
          if (entry is File && entry.path.toLowerCase().endsWith(ConverterConstants.expectedM3u8Extension)) {
            candidates.add(entry);
          }
        }
      } catch (_) {
        // Ignore filesystem list errors here, as validateInputFolder already checked permissions.
      }
    }

    if (candidates.isEmpty) {
      throw PlaylistNotFoundException(inputFolder);
    }

    return candidates;
  }

  /// Resolves the primary playlist file to use for conversion.
  Future<File> resolvePlaylist(String inputFolder) async {
    final playlists = await resolvePlaylists(inputFolder);
    return playlists.first;
  }


  /// Confirms that the `ffmpeg` executable can actually be started on
  /// this system.
  ///
  /// Throws [FFmpegNotFoundException] when the process cannot be
  /// launched (executable missing / not on PATH) or exits abnormally.
  Future<void> validateFFmpegAvailable(String ffmpegExecutable) async {
    ProcessResult result;
    try {
      result = await Process.run(
        ffmpegExecutable,
        <String>[ConverterConstants.flagVersion],
        runInShell: true,
      );
    } on ProcessException catch (e) {
      throw FFmpegNotFoundException(e.message);
    }

    if (result.exitCode != 0) {
      throw FFmpegNotFoundException(
        'ffmpeg responded with exit code ${result.exitCode}.',
      );
    }
  }

  /// Validates [outputFile]'s path and ensures its parent directory
  /// exists, creating it when missing.
  ///
  /// Throws [InvalidOutputPathException] when the path is structurally
  /// invalid, and [OutputDirectoryException] when the parent directory
  /// cannot be created or is not writable.
  Future<void> validateAndPrepareOutput(String outputFile) async {
    if (outputFile.trim().isEmpty) {
      throw InvalidOutputPathException(outputFile);
    }

    final outputAsFile = File(outputFile);
    final parentDirectory = outputAsFile.parent;

    final fileName = outputAsFile.uri.pathSegments.isNotEmpty
        ? outputAsFile.uri.pathSegments.last
        : '';
    if (fileName.trim().isEmpty) {
      throw InvalidOutputPathException(outputFile);
    }

    try {
      final exists = await parentDirectory.exists();
      if (!exists) {
        _logger.info('Output directory does not exist. Creating it...');
        await parentDirectory.create(recursive: true);
      }
    } on FileSystemException catch (e) {
      throw OutputDirectoryException(
        parentDirectory.path,
        e.message,
      );
    }

    // Verify the directory is writable by probing it with a throwaway
    // temp file, surfacing permission problems before ffmpeg runs.
    final probeFile = File(_joinPath(parentDirectory.path, _probeFileName));
    try {
      await probeFile.writeAsString('');
      await probeFile.delete();
    } on FileSystemException {
      throw OutputDirectoryException(
        parentDirectory.path,
        'directory is not writable.',
      );
    }
  }

  /// Validates [outputPath] for HLS output (which requires a directory
  /// and an `.m3u8` playlist file).
  ///
  /// Returns the resolved playlist file path (e.g. `outputDir/index.m3u8`).
  Future<String> validateAndPrepareHlsOutput(String outputPath) async {
    if (outputPath.trim().isEmpty) {
      throw InvalidOutputPathException(outputPath);
    }

    final String resolvedPlaylistPath;
    final Directory targetDirectory;

    if (outputPath.toLowerCase().endsWith(ConverterConstants.expectedM3u8Extension)) {
      resolvedPlaylistPath = outputPath;
      targetDirectory = File(outputPath).parent;
    } else {
      targetDirectory = Directory(outputPath);
      resolvedPlaylistPath = _joinPath(outputPath, ConverterConstants.primaryPlaylistName);
    }

    try {
      final exists = await targetDirectory.exists();
      if (!exists) {
        _logger.info('Output directory does not exist. Creating it...');
        await targetDirectory.create(recursive: true);
      }
    } on FileSystemException catch (e) {
      throw OutputDirectoryException(
        targetDirectory.path,
        e.message,
      );
    }

    final probeFile = File(_joinPath(targetDirectory.path, _probeFileName));
    try {
      await probeFile.writeAsString('');
      await probeFile.delete();
    } on FileSystemException {
      throw OutputDirectoryException(
        targetDirectory.path,
        'directory is not writable.',
      );
    }

    return resolvedPlaylistPath;
  }


  static const String _probeFileName = '.hls_converter_write_test.tmp';

  String _joinPath(String folder, String fileName) {
    final normalizedFolder =
        folder.endsWith(Platform.pathSeparator) || folder.endsWith('/')
            ? folder.substring(0, folder.length - 1)
            : folder;
    return '$normalizedFolder${Platform.pathSeparator}$fileName';
  }
}
