/// Whether Bluetooth can be used right now.
///
/// Lucky Lab's own type: features never see flutter_blue_plus's
/// `BluetoothAdapterState`, so the plugin behind `ble_core` stays swappable.
enum BleAdapterState {
  /// The OS has not reported a state yet (iOS needs a moment after app start).
  /// Show a neutral loading indicator, not an error.
  unknown,

  /// The device has no BLE radio, e.g. the iOS simulator.
  /// Nothing the user can do; explain it and disable BLE features.
  unsupported,

  /// The user denied the Bluetooth permission.
  /// Explain why it is needed and link to the system settings.
  unauthorized,

  /// Bluetooth is switched off.
  /// Ask the user to turn it on (Android can do it from the app, iOS cannot).
  off,

  /// Bluetooth is switching on (Android only).
  /// Kept separate from [turningOff] so the UI can say which way it is going.
  turningOn,

  /// Bluetooth is switching off (Android only). Stop scanning and connecting.
  turningOff,

  /// Bluetooth is on and the app may scan and connect.
  on;

  /// True only when the app can scan and connect.
  bool get isReady => this == on;
}
