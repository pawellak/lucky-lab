import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  test('formats bytes as uppercase hex', () {
    expect(toHex([0x02, 0x15, 0xab]), '02 15 AB');
    expect(toHex([0x0a, 0xff], separator: ''), '0AFF');
    expect(toHex([]), '');
  });
}
