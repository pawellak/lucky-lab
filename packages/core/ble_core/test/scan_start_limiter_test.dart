import 'package:ble_core/ble_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var now = DateTime(2026);
  late ScanStartLimiter limiter;

  setUp(() {
    now = DateTime(2026);
    limiter = ScanStartLimiter(now: () => now);
  });

  test('allows 5 starts within 30 s', () {
    for (var i = 0; i < 5; i++) {
      limiter.recordStart();
      now = now.add(const Duration(seconds: 1));
    }
  });

  test('refuses the 6th start and says when to retry', () {
    for (var i = 0; i < 5; i++) {
      limiter.recordStart();
      now = now.add(const Duration(seconds: 2));
    }

    // First start was 10 s ago, so it leaves the window in 20 s.
    expect(
      limiter.recordStart,
      throwsA(
        isA<BleScanThrottledException>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(seconds: 20),
        ),
      ),
    );
  });

  test('allows a start again once the oldest one leaves the window', () {
    for (var i = 0; i < 5; i++) {
      limiter.recordStart();
    }
    now = now.add(const Duration(seconds: 30));

    limiter.recordStart();
  });
}
