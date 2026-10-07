import 'dart:typed_data';

import 'package:ble_core/ble_core.dart';
import 'package:feature_scanner/src/domain/scan_filter.dart';
import 'package:feature_scanner/src/domain/scanned_device.dart';
import 'package:flutter_test/flutter_test.dart';

final t0 = DateTime(2026, 10, 8, 12);

BleScanResult result({
  String id = 'AA',
  int rssi = -60,
  Duration at = Duration.zero,
  BleAdvertisement advertisement = const BleAdvertisement(),
}) => BleScanResult(
  deviceId: id,
  rssi: rssi,
  timestamp: t0.add(at),
  advertisement: advertisement,
);

void main() {
  group('ScannedDevice', () {
    test('tracks the latest RSSI, packet count and rate', () {
      var device = ScannedDevice.fromResult(result(rssi: -70));
      for (var i = 1; i <= 10; i++) {
        device = device.update(
          result(rssi: -60, at: Duration(milliseconds: 100 * i)),
        );
      }

      expect(device.rssi, -60);
      expect(device.packetCount, 11);
      expect(device.packetsPerSecond, closeTo(10, 0.01));
      expect(device.firstSeen, t0);
    });

    test('keeps only the last 60 s of RSSI history', () {
      final device = ScannedDevice.fromResult(
        result(),
      ).update(result(at: const Duration(seconds: 61)));

      expect(device.rssiHistory, hasLength(1));
    });

    test('keeps the name when a later packet has none', () {
      final device = ScannedDevice.fromResult(
        result(advertisement: const BleAdvertisement(localName: 'Meter')),
      ).update(result(advertisement: const BleAdvertisement(txPowerLevel: 4)));

      expect(device.name, 'Meter');
      expect(device.advertisement.txPowerLevel, 4);
    });

    test('estimates distance only when the transmit power is known', () {
      expect(
        ScannedDevice.fromResult(result()).estimatedDistanceMeters,
        isNull,
      );
      expect(
        ScannedDevice.fromResult(
          result(
            rssi: -41,
            advertisement: const BleAdvertisement(txPowerLevel: 0),
          ),
        ).estimatedDistanceMeters,
        1,
      );
    });
  });

  group('ScanFilter', () {
    final named = ScannedDevice.fromResult(
      result(
        id: 'N',
        rssi: -50,
        advertisement: const BleAdvertisement(
          localName: 'Thermo',
          connectable: true,
        ),
      ),
    );
    final unnamed = ScannedDevice.fromResult(result(id: 'U', rssi: -90));
    final beacon = ScannedDevice.fromResult(
      result(
        id: 'B',
        rssi: -70,
        advertisement: FakeBleScanner.demoPeripherals[1].advertisement,
      ),
    );
    final all = [unnamed, beacon, named];

    test('shows everything by default, strongest first', () {
      expect(const ScanFilter().apply(all), [named, beacon, unnamed]);
      expect(const ScanFilter().isActive, isFalse);
    });

    test('filters by minimum RSSI', () {
      expect(const ScanFilter(minRssi: -75).apply(all), [named, beacon]);
    });

    test('filters by name, connectable and beacon', () {
      expect(const ScanFilter(namedOnly: true).apply(all), [named]);
      expect(const ScanFilter(connectableOnly: true).apply(all), [named]);
      expect(const ScanFilter(beaconsOnly: true).apply(all), [beacon]);
    });

    test('filters by advertised service UUIDs or service data', () {
      final withUuid = ScannedDevice.fromResult(
        result(
          id: 'S',
          advertisement: BleAdvertisement(
            serviceUuids: [BleUuid.from16(0x180D)],
          ),
        ),
      );
      final withData = ScannedDevice.fromResult(
        result(
          id: 'D',
          rssi: -80,
          advertisement: BleAdvertisement(
            serviceData: {BleUuid.from16(0xFEAA): Uint8List(0)},
          ),
        ),
      );

      const filter = ScanFilter(servicesOnly: true);
      expect(filter.apply([...all, withUuid, withData]), [withUuid, withData]);
      expect(filter.isActive, isTrue);
    });

    test('filters by the TX power field', () {
      final withTxPower = ScannedDevice.fromResult(
        result(
          id: 'T',
          advertisement: const BleAdvertisement(txPowerLevel: 12),
        ),
      );

      const filter = ScanFilter(txPowerOnly: true);
      expect(filter.apply([...all, withTxPower]), [withTxPower]);
      expect(filter.isActive, isTrue);
    });

    test('searches name, address and manufacturer, ignoring case', () {
      expect(const ScanFilter(query: 'therm').apply(all), [named]);
      expect(const ScanFilter(query: 'u').apply(all), contains(unnamed));
      expect(const ScanFilter(query: 'APPLE').apply(all), [beacon]);
    });

    test('sorts named devices alphabetically before unnamed ones', () {
      expect(const ScanFilter(sort: ScanSort.name).apply(all), [
        named,
        beacon,
        unnamed,
      ]);
    });
  });
}
