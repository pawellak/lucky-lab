import 'ble_adapter_state.dart';

/// Reports whether Bluetooth can be used.
///
/// Features depend on this interface, never on a concrete BLE plugin.
abstract interface class BleAdapter {
  /// The current adapter state, followed by every change.
  ///
  /// A new listener receives the current state immediately, so a screen
  /// opened while Bluetooth is already off shows that straight away
  /// instead of waiting for the next change.
  Stream<BleAdapterState> get state;

  /// Whether [turnOn] works on this platform. Only Android lets an app
  /// switch Bluetooth on; iOS users have to do it themselves.
  bool get canTurnOn;

  /// Asks the system to switch Bluetooth on. Android only, see [canTurnOn].
  Future<void> turnOn();
}
