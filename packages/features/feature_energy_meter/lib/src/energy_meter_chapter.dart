import 'package:shared/shared.dart';

const energyMeterChapter = ChapterInfo(
  number: 3,
  slug: 'energy-meter',
  tier: ChapterTier.core,
  title: 'Energy Meter + Custom GATT',
  summary:
      'Build your own BLE power meter (INA226 on ESP32 / nRF) with a custom GATT service, live notifications and settings over write.',
  learningGoals: [
    'GATT service and characteristic design',
    'Choosing an address type: static vs RPA',
    'Operation queue for GATT requests',
    'MTU negotiation',
    'Reconnection state machine',
    'First firmware: GATT server on ESP32 / nRF',
  ],
  bonusGoals: [
    'Shunt sizing and INA226 calibration',
    'Low-power firmware and measured battery life (Power Profiler Kit)',
    'Debugging I2C with an oscilloscope / logic analyzer',
  ],
  needsHardware: true,
);
