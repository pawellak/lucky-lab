import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  test('ChapterInfo defaults to not started and no hardware', () {
    const info = ChapterInfo(
      number: 1,
      slug: 'test',
      track: ChapterTrack.bleIot,
      title: 'Test',
      summary: 'Summary',
      learningGoals: [],
    );

    expect(info.status, ChapterStatus.notStarted);
    expect(info.needsHardware, isFalse);
  });
}
