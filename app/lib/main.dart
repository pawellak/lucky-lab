import 'package:ble_core/ble_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/lucky_lab_app.dart';

/// `flutter run --dart-define=FAKE_BLE=true` swaps the real Bluetooth stack
/// for demo devices, e.g. on the iOS simulator, which has no Bluetooth.
const _fakeBle = bool.fromEnvironment('FAKE_BLE');

void main() {
  runApp(
    ProviderScope(
      overrides: [
        if (_fakeBle) ...[
          bleAdapterProvider.overrideWithValue(FakeBleAdapter()),
          bleScannerProvider.overrideWithValue(FakeBleScanner()),
        ],
      ],
      child: const LuckyLabApp(),
    ),
  );
}
