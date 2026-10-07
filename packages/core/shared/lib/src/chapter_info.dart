/// Progress of a single learning chapter.
enum ChapterStatus { notStarted, inProgress, done }

/// Group of chapters shown together on the dashboard.
enum ChapterTrack {
  bleIot('BLE & IoT'),
  production('Production skills');

  const ChapterTrack(this.title);

  final String title;
}

/// Static description of one Lucky Lab chapter.
///
/// Every feature package exposes exactly one [ChapterInfo]; the app shell
/// uses it to build the dashboard card and the chapter route.
class ChapterInfo {
  const ChapterInfo({
    required this.number,
    required this.slug,
    required this.track,
    required this.title,
    required this.summary,
    required this.learningGoals,
    this.needsHardware = false,
    this.status = ChapterStatus.notStarted,
  });

  /// 1-based position in the learning path.
  final int number;

  /// URL-safe identifier, used as the route path segment.
  final String slug;

  final ChapterTrack track;
  final String title;
  final String summary;
  final List<String> learningGoals;

  /// Whether the chapter requires an ESP32/nRF board or another BLE device.
  final bool needsHardware;

  /// Updated by hand as the chapter progresses.
  final ChapterStatus status;
}
