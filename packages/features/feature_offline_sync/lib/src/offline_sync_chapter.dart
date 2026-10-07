import 'package:shared/shared.dart';

const offlineSyncChapter = ChapterInfo(
  number: 9,
  slug: 'offline-sync',
  tier: ChapterTier.optional,
  title: 'Offline-First Sync',
  summary:
      'Store energy readings locally and sync them with a backend, so the app keeps working with no network.',
  learningGoals: [
    'Local database (Drift / SQLite)',
    'Sync queue and conflict resolution',
    'Background sync (WorkManager / BGTaskScheduler)',
    'Connectivity handling and retries',
  ],
);
