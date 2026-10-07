import 'package:shared/shared.dart';

const releaseChapter = ChapterInfo(
  number: 8,
  slug: 'release',
  tier: ChapterTier.differentiator,
  title: 'Release & Observability',
  summary:
      'Ship like a product team: flavors, CI/CD to the stores, crash reporting, monitoring and tests against real hardware.',
  learningGoals: [
    'Flavors and environments',
    'CI/CD to App Store and Google Play (Fastlane)',
    'Code signing and store releases',
    'Crash reporting and structured logging',
    'Performance profiling with DevTools',
    'Hardware-in-the-loop tests: real ESP32 in CI',
  ],
);
