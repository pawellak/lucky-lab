import 'package:shared/shared.dart';

const sensorChapter = ChapterInfo(
  number: 2,
  slug: 'sensor',
  track: ChapterTrack.bleIot,
  title: 'Sensor + Custom GATT',
  summary:
      'ESP32/nRF temperature & humidity sensor with a custom GATT service, notifications and settings over write.',
  learningGoals: [
    'GATT service and characteristic design',
    'Operation queue for GATT requests',
    'MTU negotiation',
    'Reconnection state machine',
  ],
  needsHardware: true,
);
