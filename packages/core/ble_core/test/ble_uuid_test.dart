import 'package:ble_core/ble_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expands a 16-bit UUID on the Base UUID', () {
    expect(BleUuid.from16(0xFEAA), '0000feaa-0000-1000-8000-00805f9b34fb');
  });

  test('shortens UUIDs built on the Base UUID only', () {
    expect(BleUuid.short(BleUuid.from16(0x180F)), '180F');
    expect(
      BleUuid.short('6E400001-B5A3-F393-E0A9-E50E24DCCA9E'),
      '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
    );
  });
}
