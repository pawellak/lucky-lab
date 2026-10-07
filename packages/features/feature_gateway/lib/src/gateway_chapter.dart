import 'package:shared/shared.dart';

const gatewayChapter = ChapterInfo(
  number: 6,
  slug: 'gateway',
  track: ChapterTrack.bleIot,
  title: 'BLE → MQTT Gateway',
  summary:
      'An ESP32 gateway that bridges many BLE devices to Wi-Fi / MQTT at once.',
  learningGoals: [
    'Central role on a microcontroller',
    'Passive scanning',
    'Multiple concurrent connections',
    'Bridging BLE data to MQTT',
  ],
  needsHardware: true,
);
