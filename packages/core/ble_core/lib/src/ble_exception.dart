/// Errors that `ble_core` reports to features, in place of plugin-specific
/// exceptions.
sealed class BleException implements Exception {
  const BleException(this.message);

  /// Human-readable description, safe to show in the UI.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A BLE operation failed in the plugin or the OS, e.g. a missing
/// permission or location services being off.
final class BleOperationException extends BleException {
  const BleOperationException(super.message);
}

/// Android refuses to start a scan: an app may start at most 5 scans in
/// 30 seconds. Above that the OS does not fail; it silently returns no
/// results, so we stop earlier and say why. See [ScanStartLimiter].
final class BleScanThrottledException extends BleException {
  BleScanThrottledException(this.retryAfter)
    : super(
        'Android allows 5 scan starts per 30 s. '
        'Try again in ${(retryAfter.inMilliseconds / 1000).ceil()} s.',
      );

  final Duration retryAfter;
}
