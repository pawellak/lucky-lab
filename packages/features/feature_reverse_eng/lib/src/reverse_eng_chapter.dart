import 'package:shared/shared.dart';

const reverseEngChapter = ChapterInfo(
  number: 6,
  slug: 'reverse-engineering',
  tier: ChapterTier.differentiator,
  title: 'Reverse Engineering',
  summary:
      'Reverse-engineer a cheap commercial device (LED strip, Xiaomi thermometer) and control it from this app.',
  learningGoals: [
    'Sniffing with nRF Sniffer + Wireshark',
    'Android HCI snoop logs',
    'Capturing a pairing: SMP, keys and the legacy Just Works weakness',
    'Protocol analysis of unknown devices',
    'Hardware side: finding UART / SWD pads and dumping firmware',
  ],
  needsHardware: true,
);
