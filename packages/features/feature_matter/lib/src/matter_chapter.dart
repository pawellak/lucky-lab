import 'package:shared/shared.dart';

const matterChapter = ChapterInfo(
  number: 14,
  slug: 'matter',
  track: ChapterTrack.bleIot,
  title: 'Matter & Thread',
  summary:
      'Commission a Matter smart-home device over BLE and control it over Thread / Wi-Fi.',
  learningGoals: [
    'Matter data model: nodes, endpoints, clusters',
    'BLE commissioning flow',
    'Thread networking and border routers',
    'Matter on ESP32 (esp-matter)',
    'Apple Home / Google Home platform APIs',
  ],
  needsHardware: true,
);
