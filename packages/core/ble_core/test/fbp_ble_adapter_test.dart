import 'package:ble_core/ble_core.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps every FBP adapter state', () {
    const expected = {
      BluetoothAdapterState.unknown: BleAdapterState.unknown,
      BluetoothAdapterState.unavailable: BleAdapterState.unsupported,
      BluetoothAdapterState.unauthorized: BleAdapterState.unauthorized,
      BluetoothAdapterState.off: BleAdapterState.off,
      BluetoothAdapterState.turningOn: BleAdapterState.turningOn,
      BluetoothAdapterState.turningOff: BleAdapterState.turningOff,
      BluetoothAdapterState.on: BleAdapterState.on,
    };

    expect(expected.keys, unorderedEquals(BluetoothAdapterState.values));
    for (final MapEntry(key: fbp, value: ours) in expected.entries) {
      expect(FbpBleAdapter.toBleAdapterState(fbp), ours, reason: '$fbp');
    }
  });

  test('only on is ready', () {
    final ready = BleAdapterState.values.where((s) => s.isReady);
    expect(ready, [BleAdapterState.on]);
  });
}
