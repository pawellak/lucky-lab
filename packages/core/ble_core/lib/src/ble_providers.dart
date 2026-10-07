import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ble_adapter.dart';
import 'ble_adapter_state.dart';
import 'ble_scanner.dart';
import 'fbp_ble_adapter.dart';
import 'fbp_ble_scanner.dart';

/// The app's [BleAdapter]. Overridden with a fake in tests and in
/// `FAKE_BLE` mode.
final bleAdapterProvider = Provider<BleAdapter>((ref) => const FbpBleAdapter());

/// The app's [BleScanner]. Overridden like [bleAdapterProvider].
final bleScannerProvider = Provider<BleScanner>((ref) => FbpBleScanner());

/// Current Bluetooth state, kept up to date.
final bleAdapterStateProvider = StreamProvider<BleAdapterState>(
  (ref) => ref.watch(bleAdapterProvider).state,
);
