import 'package:shared/shared.dart';

const reverseEngChapter = ChapterInfo(
  number: 5,
  slug: 'reverse-engineering',
  track: ChapterTrack.bleIot,
  title: 'Reverse Engineering',
  summary:
      'Reverse-engineer a cheap commercial device (LED strip, Xiaomi thermometer) and control it from this app.',
  learningGoals: [
    'Sniffing with nRF Sniffer + Wireshark',
    'Android HCI snoop logs',
    'Protocol analysis of unknown devices',
  ],
  needsHardware: true,
);
