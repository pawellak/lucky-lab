import 'dart:typed_data';

import 'package:ble_core/ble_core.dart';
import 'package:feature_scanner/src/domain/advertisement_decoder.dart';
import 'package:feature_scanner/src/domain/advertisement_payload.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List bytes(List<int> list) => Uint8List.fromList(list);

void main() {
  group('iBeacon', () {
    final valid = bytes([
      0x02, 0x15, //
      0xE2, 0xC5, 0x6D, 0xB5, 0xDF, 0xFB, 0x48, 0xD2, //
      0xB0, 0x60, 0xD0, 0xF5, 0xA7, 0x10, 0x96, 0xE0, //
      0x01, 0x02, 0x00, 0x2A, 0xC5, //
    ]);

    test('decodes UUID, big-endian major/minor and signed power', () {
      final beacon = AdvertisementDecoder.decodeIBeacon(valid)!;

      expect(beacon.proximityUuid, 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0');
      expect(beacon.major, 0x0102);
      expect(beacon.minor, 42);
      expect(beacon.measuredPower, -59);
    });

    test('rejects other Apple payloads and truncated packets', () {
      expect(
        AdvertisementDecoder.decodeIBeacon(bytes([0x10, 0x05, 0x01])),
        isNull,
      );
      expect(AdvertisementDecoder.decodeIBeacon(valid.sublist(0, 20)), isNull);
    });

    test('is only looked for in Apple manufacturer data', () {
      final ad = BleAdvertisement(manufacturerData: {0x0059: valid});
      expect(AdvertisementDecoder.decode(ad), isEmpty);
    });
  });

  group('Eddystone', () {
    test('decodes a UID frame', () {
      final payload = AdvertisementDecoder.decodeEddystone(
        bytes([
          0x00, 0xEE, //
          0xED, 0xD1, 0xEB, 0xEA, 0xC0, 0x4E, 0x5D, 0xEF, 0xA0, 0x17, //
          0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, //
        ]),
      );

      expect(
        payload,
        isA<EddystoneUidPayload>()
            .having((p) => p.txPowerAt0m, 'tx', -18)
            .having((p) => p.namespace, 'namespace', 'EDD1EBEAC04E5DEFA017')
            .having((p) => p.instance, 'instance', '000000000007'),
      );
    });

    test('decodes a URL frame with scheme and expansion codes', () {
      // https://www. + "example" + .com/ + "x"
      final payload = AdvertisementDecoder.decodeEddystone(
        bytes([0x10, 0xEC, 0x01, ...'example'.codeUnits, 0x00, 0x78]),
      );

      expect(
        payload,
        isA<EddystoneUrlPayload>()
            .having((p) => p.url, 'url', 'https://www.example.com/x')
            .having((p) => p.txPowerAt0m, 'tx', -20),
      );
    });

    test('rejects a URL with an unknown scheme or a control character', () {
      expect(
        AdvertisementDecoder.decodeEddystone(bytes([0x10, 0x00, 0x09, 0x61])),
        isNull,
      );
      expect(
        AdvertisementDecoder.decodeEddystone(
          bytes([0x10, 0x00, 0x03, 0x0A + 0x10]),
        ),
        isNull,
      );
    });

    test('decodes a TLM frame, including the 8.8 fixed-point temperature', () {
      final payload = AdvertisementDecoder.decodeEddystone(
        bytes([
          0x20, 0x00, 0x0B, 0xC4, 0xFF, 0x80, //
          0x00, 0x00, 0x04, 0xB0, 0x00, 0x00, 0x8C, 0xA0, //
        ]),
      );

      expect(
        payload,
        isA<EddystoneTlmPayload>()
            .having((p) => p.batteryMillivolts, 'battery', 3012)
            .having((p) => p.temperatureCelsius, 'temperature', -0.5)
            .having((p) => p.advertisingCount, 'count', 1200)
            .having((p) => p.uptime, 'uptime', const Duration(hours: 1)),
      );
    });

    test('reports unsupported TLM fields as null', () {
      final payload =
          AdvertisementDecoder.decodeEddystone(
                bytes([0x20, 0x00, 0, 0, 0x80, 0x00, 0, 0, 0, 0, 0, 0, 0, 0]),
              )!
              as EddystoneTlmPayload;

      expect(payload.batteryMillivolts, isNull);
      expect(payload.temperatureCelsius, isNull);
    });

    test('ignores unknown frame types and empty data', () {
      expect(AdvertisementDecoder.decodeEddystone(bytes([0x30, 0x00])), isNull);
      expect(AdvertisementDecoder.decodeEddystone(bytes([])), isNull);
    });
  });

  test('finds every format in the demo peripherals', () {
    final labels = {
      for (final p in FakeBleScanner.demoPeripherals)
        for (final payload in AdvertisementDecoder.decode(p.advertisement))
          payload.label,
    };

    expect(labels, {
      'iBeacon',
      'Eddystone-UID',
      'Eddystone-URL',
      'Eddystone-TLM',
    });
  });

  test('estimates distance from RSSI', () {
    expect(estimateDistanceMeters(rssi: -59, measuredPowerAt1m: -59), 1);
    expect(estimateDistanceMeters(rssi: -79, measuredPowerAt1m: -59), 10);
  });
}
