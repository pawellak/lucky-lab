/// Progress of a single learning chapter.
enum ChapterStatus { notStarted, inProgress, done }

/// Priority group of a chapter, shown as a dashboard section.
enum ChapterTier {
  core('Core', 'What BLE job offers ask for'),
  differentiator('Differentiators', 'What makes you stand out'),
  optional('Optional', 'If there is time, or a job offer needs it');

  const ChapterTier(this.title, this.description);

  final String title;
  final String description;
}

/// Static description of one Lucky Lab chapter.
///
/// Every feature package exposes exactly one [ChapterInfo]; the app shell
/// uses it to build the dashboard card and the chapter route.
class ChapterInfo {
  const ChapterInfo({
    required this.number,
    required this.slug,
    required this.tier,
    required this.title,
    required this.summary,
    required this.learningGoals,
    this.bonusGoals = const [],
    this.needsHardware = false,
    this.status = ChapterStatus.notStarted,
  });

  /// 1-based position in the learning path.
  final int number;

  /// URL-safe identifier, used as the route path segment.
  final String slug;

  final ChapterTier tier;
  final String title;
  final String summary;
  final List<String> learningGoals;

  /// Nice-to-have extras, e.g. electronics work that job offers don't ask for.
  final List<String> bonusGoals;

  /// Whether the chapter requires an ESP32/nRF board or another BLE device.
  final bool needsHardware;

  /// Updated by hand as the chapter progresses.
  final ChapterStatus status;
}
