import 'package:shared/shared.dart';

const otaChapter = ChapterInfo(
  number: 3,
  slug: 'ota',
  track: ChapterTrack.bleIot,
  title: 'OTA Firmware Update',
  summary:
      'Update the chapter 2 device\'s firmware over BLE using MCUboot and the SMP protocol.',
  learningGoals: [
    'Throughput: MTU, Data Length Extension, 2M PHY',
    'Write without response and flow control',
    'Resuming an interrupted transfer',
    'MCUboot image slots and SMP',
  ],
  needsHardware: true,
);
