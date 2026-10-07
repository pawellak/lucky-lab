import 'package:shared/shared.dart';

const smartHomeChapter = ChapterInfo(
  number: 13,
  slug: 'smart-home',
  tier: ChapterTier.optional,
  title: 'Smart Home & Bluetooth 6.0',
  summary:
      'Matter and Thread smart-home devices, plus the newest Bluetooth features: Mesh, direction finding, Channel Sounding and LE Audio.',
  learningGoals: [
    'Matter: data model and BLE commissioning',
    'Thread networking and esp-matter',
    'BLE Mesh',
    'Direction finding (AoA / AoD)',
    'Channel Sounding (Bluetooth 6.0)',
    'LE Audio',
  ],
  needsHardware: true,
);
