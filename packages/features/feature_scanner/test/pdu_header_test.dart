import 'package:ble_core/ble_core.dart';
import 'package:feature_scanner/src/domain/packet_field.dart';
import 'package:feature_scanner/src/domain/pdu_header.dart';
import 'package:feature_scanner/src/domain/scanned_device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ScannedDevice device(String id, {bool connectable = false}) =>
      ScannedDevice.fromResult(
        BleScanResult(
          deviceId: id,
          rssi: -60,
          timestamp: DateTime(2026, 10, 23),
          advertisement: BleAdvertisement(connectable: connectable),
        ),
      );

  test('covers both bytes: 8 bits each', () {
    final fields = describePduHeader(device('F0:12:A7:33:9C:02'));
    int bits(int byte) =>
        fields.where((f) => f.byte == byte).fold(0, (sum, f) => sum + f.width);

    expect(bits(0), 8);
    expect(bits(1), 8);
  });

  test('only the PDU type is received, narrowed by connectable', () {
    final beacon = describePduHeader(device('F0:12:A7:33:9C:02'));
    final band = describePduHeader(
      device('E7:0F:5B:62:A4:07', connectable: true),
    );

    expect(beacon.first.status, FieldStatus.received);
    expect(beacon.first.value, contains('ADV_NONCONN_IND'));
    expect(band.first.value, contains('ADV_IND'));
    expect(
      beacon.skip(1).map((f) => f.status),
      everyElement(FieldStatus.hidden),
    );
  });

  test('reads the random address kind from the top two bits', () {
    expect(randomAddressKind('F0:12:A7:33:9C:02'), startsWith('static'));
    expect(randomAddressKind('4A:91:3C:E8:0B:06'), startsWith('resolvable'));
    expect(
      randomAddressKind('12:34:56:78:9A:BC'),
      startsWith('non-resolvable'),
    );
    expect(randomAddressKind('8C:85:90:00:00:01'), startsWith('reserved'));
    expect(randomAddressKind('6E0D3B4A-1F2C-4C8B-9E2A-5B7D8C9E0F11'), isNull);
  });
}
