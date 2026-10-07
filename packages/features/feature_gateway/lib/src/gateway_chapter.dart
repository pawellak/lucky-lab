import 'package:shared/shared.dart';

const gatewayChapter = ChapterInfo(
  number: 9,
  slug: 'gateway',
  tier: ChapterTier.optional,
  title: 'BLE → MQTT Gateway',
  summary:
      'An ESP32 gateway that collects data from many energy meters over BLE and publishes it over Wi-Fi / MQTT.',
  learningGoals: [
    'Central role on a microcontroller',
    'Passive scanning',
    'Multiple concurrent connections',
    'Bridging BLE data to MQTT',
  ],
  needsHardware: true,
);
