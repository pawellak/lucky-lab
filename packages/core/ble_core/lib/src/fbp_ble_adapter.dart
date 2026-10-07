import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_adapter.dart';
import 'ble_adapter_state.dart';

/// [BleAdapter] backed by flutter_blue_plus.
///
/// The only place in Lucky Lab that knows FBP's adapter types.
final class FbpBleAdapter implements BleAdapter {
  const FbpBleAdapter();

  /// FBP already emits the current state first, as [BleAdapter.state] requires.
  @override
  Stream<BleAdapterState> get state =>
      FlutterBluePlus.adapterState.map(toBleAdapterState);

  @override
  bool get canTurnOn => defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> turnOn() {
    if (!canTurnOn) {
      throw UnsupportedError('Only Android lets an app turn Bluetooth on.');
    }
    return FlutterBluePlus.turnOn();
  }

  /// Maps FBP's state to ours. Exhaustive, so a state added to FBP in a
  /// future version breaks the build here instead of slipping through.
  static BleAdapterState toBleAdapterState(BluetoothAdapterState state) =>
      switch (state) {
        BluetoothAdapterState.unknown => BleAdapterState.unknown,
        BluetoothAdapterState.unavailable => BleAdapterState.unsupported,
        BluetoothAdapterState.unauthorized => BleAdapterState.unauthorized,
        BluetoothAdapterState.off => BleAdapterState.off,
        BluetoothAdapterState.turningOn => BleAdapterState.turningOn,
        BluetoothAdapterState.turningOff => BleAdapterState.turningOff,
        BluetoothAdapterState.on => BleAdapterState.on,
      };
}
