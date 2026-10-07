import 'ble_scan_result.dart';

/// Discovers nearby peripherals by listening to their advertisements.
abstract interface class BleScanner {
  /// Every advertising packet received while scanning, one by one, so a
  /// device that advertises ten times a second appears ten times.
  ///
  /// Listen before calling [start]. Scan failures arrive as
  /// `BleException` errors.
  Stream<BleScanResult> get results;

  /// Whether a scan is running. Emits the current value first.
  Stream<bool> get isScanning;

  /// Starts scanning. Throws `BleScanThrottledException` when Android
  /// would ignore the start, or `BleOperationException` when it fails.
  Future<void> start();

  Future<void> stop();
}
