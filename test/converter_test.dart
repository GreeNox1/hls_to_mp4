import 'package:hls_to_mp4/hls_to_mp4.dart';
import 'package:test/test.dart';

void main() {
  group('CommandBuilder tests', () {
    test('HlsToMp4CommandBuilder generates valid ffmpeg argument list', () {
      const builder = HlsToMp4CommandBuilder();
      final args = builder.build(
        inputPath: 'C:/media/index.m3u8',
        outputPath: 'C:/media/video.mp4',
      );

      expect(args, equals(['-i', 'C:/media/index.m3u8', '-c', 'copy', '-y', 'C:/media/video.mp4']));
    });

    test('Mp4ToHlsCommandBuilder generates valid HLS argument list', () {
      const builder = Mp4ToHlsCommandBuilder(segmentTimeSeconds: 5);
      final args = builder.build(
        inputPath: 'C:/media/video.mp4',
        outputPath: 'C:/media/hls/index.m3u8',
      );

      expect(
        args,
        equals([
          '-i',
          'C:/media/video.mp4',
          '-c',
          'copy',
          '-start_number',
          '0',
          '-hls_time',
          '5',
          '-hls_list_size',
          '0',
          '-f',
          'hls',
          '-y',
          'C:/media/hls/index.m3u8',
        ]),
      );
    });
  });

  group('Validator tests', () {
    test('validateAndPrepareOutput throws InvalidOutputPathException for empty string', () async {
      const validator = Validator(ConsoleLogger());
      expect(
        () => validator.validateAndPrepareOutput('   '),
        throwsA(isA<InvalidOutputPathException>()),
      );
    });

    test('validateAndPrepareHlsOutput throws InvalidOutputPathException for empty string', () async {
      const validator = Validator(ConsoleLogger());
      expect(
        () => validator.validateAndPrepareHlsOutput('   '),
        throwsA(isA<InvalidOutputPathException>()),
      );
    });
  });
}
