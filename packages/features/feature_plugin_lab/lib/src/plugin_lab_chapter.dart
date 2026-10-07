import 'package:shared/shared.dart';

const pluginLabChapter = ChapterInfo(
  number: 2,
  slug: 'plugin-lab',
  tier: ChapterTier.core,
  title: 'Native Flutter Plugin',
  summary:
      'Re-implement chapter 1\'s scanner natively in Kotlin and Swift as your own Flutter plugin, then add peripheral mode or L2CAP.',
  learningGoals: [
    'Kotlin, coroutines and Flow',
    'android.bluetooth in depth',
    'CoreBluetooth in depth',
    'Platform channels / Pigeon',
    'Peripheral role or L2CAP CoC',
    'Shared native core in Kotlin Multiplatform (KMP)',
  ],
);
