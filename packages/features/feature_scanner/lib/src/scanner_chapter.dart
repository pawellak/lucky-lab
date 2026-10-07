import 'package:shared/shared.dart';

const scannerChapter = ChapterInfo(
  number: 1,
  slug: 'scanner',
  tier: ChapterTier.core,
  status: ChapterStatus.inProgress,
  title: 'BLE Scanner & Analyzer',
  summary:
      'Scan nearby devices and decode iBeacon, Eddystone and manufacturer data, with a live RSSI chart and filters.',
  learningGoals: [
    'GAP roles and advertising',
    'Advertising packet format (AD structures)',
    'Byte-level parsing of advertising payloads',
    'Android scan limits and throttling',
  ],
);
