import 'dart:collection';

import 'ble_exception.dart';

/// Tracks scan starts so we never exceed Android's limit.
///
/// Since Android 7 an app may start at most 5 scans in a 30-second
/// window. The sixth start does not fail: the OS just delivers no results
/// and logs "App is scanning too frequently". This class turns that
/// silent failure into a [BleScanThrottledException] with a retry time.
final class ScanStartLimiter {
  ScanStartLimiter({
    this.maxStarts = 5,
    this.window = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final int maxStarts;
  final Duration window;
  final DateTime Function() _now;
  final _starts = Queue<DateTime>();

  /// Records a start, or throws if it would exceed the limit.
  void recordStart() {
    final now = _now();
    while (_starts.isNotEmpty && now.difference(_starts.first) >= window) {
      _starts.removeFirst();
    }
    if (_starts.length >= maxStarts) {
      throw BleScanThrottledException(window - now.difference(_starts.first));
    }
    _starts.addLast(now);
  }
}
