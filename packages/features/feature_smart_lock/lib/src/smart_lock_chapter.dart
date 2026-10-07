import 'package:shared/shared.dart';

const smartLockChapter = ChapterInfo(
  number: 5,
  slug: 'smart-lock',
  tier: ChapterTier.core,
  title: 'Proximity Smart Lock',
  summary:
      'A lock / gate opener that unlocks automatically when you walk up to it.',
  learningGoals: [
    'Bonding and pairing',
    'LE Secure Connections',
    'Privacy: RPAs, IRK and resolving lists',
    'Custom challenge-response authentication',
    'iOS and Android background behaviour',
  ],
  bonusGoals: ['Driving a relay / door strike safely from the MCU'],
  needsHardware: true,
);
