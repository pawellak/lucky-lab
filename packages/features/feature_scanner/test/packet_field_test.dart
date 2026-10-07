import 'dart:typed_data';

import 'package:ble_core/ble_core.dart';
import 'package:feature_scanner/src/domain/appearance.dart';
import 'package:feature_scanner/src/domain/packet_field.dart';
import 'package:feature_scanner/src/domain/scanned_device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ScannedDevice device(String id, BleAdvertisement advertisement) =>
      ScannedDevice.fromResult(
        BleScanResult(
          deviceId: id,
          rssi: -60,
          timestamp: DateTime(2026, 10, 23),
          advertisement: advertisement,
        ),
      );

  Map<int, FieldStatus> statuses(ScannedDevice device, {bool isIos = false}) =>
      {
        for (final field in describePacket(device, isIos: isIos))
          field.number: field.status,
      };

  final iBeacon = BleAdvertisement(manufacturerData: {0x004C: Uint8List(23)});

  test('radio-only parts are always hidden', () {
    final result = statuses(device('F0:12:A7:33:9C:02', iBeacon));

    expect(result[1], FieldStatus.hidden); // preamble
    expect(result[2], FieldStatus.hidden); // access address
    expect(result[5], FieldStatus.hidden); // flags
    expect(result[13], FieldStatus.hidden); // CRC
  });

  test('fields the device sends are green, missing ones purple', () {
    final result = statuses(device('F0:12:A7:33:9C:02', iBeacon));

    expect(result[4], FieldStatus.received); // MAC address on Android
    expect(result[11], FieldStatus.received); // manufacturer data
    expect(result[6], FieldStatus.notSent); // name
    expect(result[9], FieldStatus.notSent); // service UUIDs
    expect(result[8], FieldStatus.notSent); // appearance
  });

  test('iOS hides the address and appearance', () {
    final result = statuses(
      device('6E0D3B4A-1F2C-4C8B-9E2A-5B7D8C9E0F11', iBeacon),
      isIos: true,
    );

    expect(result[4], FieldStatus.hidden);
    expect(result[8], FieldStatus.hidden);
  });

  test('sizes count the AD header bytes', () {
    final fields = describePacket(
      device(
        'F0:12:A7:33:9C:02',
        BleAdvertisement(
          localName: 'Lucky',
          serviceUuids: [BleUuid.from16(0x180F), BleUuid.from16(0x181A)],
          uuidByteLengths: {
            BleUuid.from16(0x180F): 2,
            BleUuid.from16(0x181A): 2,
          },
          manufacturerData: {0x004C: Uint8List(23)},
        ),
      ),
      isIos: false,
    );
    String size(int number) =>
        fields.firstWhere((f) => f.number == number).size;

    expect(size(6), '7 B'); // 05 09 'L' 'u' 'c' 'k' 'y'
    expect(size(9), '6 B'); // 05 03 0F 18 1A 18
    expect(size(11), '27 B'); // 1A FF 4C 00 + 23 bytes: the iBeacon
  });

  test('describes appearance category and subcategory', () {
    expect(describeAppearance(0x00C1), '0x00C1 (Watch, subcategory 1)');
    expect(describeAppearance(0x0340), '0x0340 (Heart rate sensor)');
  });
}
