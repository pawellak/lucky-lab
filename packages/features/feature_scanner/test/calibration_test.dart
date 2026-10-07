import 'package:feature_scanner/src/domain/calibration.dart';
import 'package:feature_scanner/src/domain/scanned_device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<RssiSample> samples(List<int> rssi) => [
    for (final (i, value) in rssi.indexed)
      RssiSample(DateTime(2026, 10, 23, 12, 0, i), value),
  ];

  test('needs at least five packets', () {
    expect(calibrateAt1m(samples([-50, -51, -52, -53])), isNull);
  });

  test('takes the median, so multipath dips do not drag it down', () {
    final calibration = calibrateAt1m(samples([-54, -53, -75, -55, -54]))!;

    expect(calibration.referencePower, -54); // the mean would be -58
    expect(calibration.sampleCount, 5);
    expect(calibration.weakest, -75);
    expect(calibration.strongest, -53);
  });

  test('runs the TX power formula backwards', () {
    final calibration = calibrateAt1m(samples([-54, -54, -54, -54, -54]))!;

    expect(calibration.measuredTxPower, -13); // -54 + 41
  });

  test('averages the two middle values for an even count', () {
    final calibration = calibrateAt1m(samples([-50, -52, -54, -56, -58, -60]));

    expect(calibration!.referencePower, -55);
  });
}
