import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  test('converts dBm to milliwatts', () {
    expect(dbmToMilliwatts(0), 1);
    expect(dbmToMilliwatts(20), closeTo(100, 1e-9));
    expect(dbmToMilliwatts(-30), closeTo(0.001, 1e-12));
  });

  test('formats dBm with the linear value in the closest unit', () {
    expect(formatDbm(0), '0 dBm (1 mW)');
    expect(formatDbm(12), '12 dBm (15.8 mW)');
    expect(formatDbm(20), '20 dBm (100 mW)');
    expect(formatDbm(-4), '-4 dBm (398 µW)');
    expect(formatDbm(-48), '-48 dBm (15.8 nW)');
    expect(formatDbm(-59), '-59 dBm (1.26 nW)');
    expect(formatDbm(-100), '-100 dBm (100 fW)');
  });
}
