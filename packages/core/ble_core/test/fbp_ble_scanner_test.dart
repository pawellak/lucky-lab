import 'package:ble_core/ble_core.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps an FBP scan result to ours', () {
    final timestamp = DateTime(2026, 10, 8);
    final result = FbpBleScanner.toBleScanResult(
      ScanResult(
        device: BluetoothDevice(remoteId: const DeviceIdentifier('AA:BB')),
        rssi: -60,
        timeStamp: timestamp,
        advertisementData: AdvertisementData(
          advName: 'Sensor',
          txPowerLevel: -4,
          appearance: 0x00C1,
          connectable: true,
          manufacturerData: {
            0x0059: [1, 2],
          },
          serviceData: {
            Guid('feaa'): [0x10],
          },
          serviceUuids: [
            Guid('180f'),
            Guid('6e400001-b5a3-f393-e0a9-e50e24dcca9e'),
          ],
        ),
      ),
    );

    expect(result.deviceId, 'AA:BB');
    expect(result.rssi, -60);
    expect(result.timestamp, timestamp);
    final ad = result.advertisement;
    expect(ad.localName, 'Sensor');
    expect(ad.txPowerLevel, -4);
    expect(ad.appearance, 0x00C1);
    expect(ad.connectable, isTrue);
    expect(ad.manufacturerData[0x0059], [1, 2]);
    expect(ad.serviceData[BleUuid.from16(0xFEAA)], [0x10]);
    expect(ad.serviceUuids, [
      BleUuid.from16(0x180F),
      '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
    ]);
    expect(ad.uuidByteLengths, {
      BleUuid.from16(0x180F): 2,
      '6e400001-b5a3-f393-e0a9-e50e24dcca9e': 16,
      BleUuid.from16(0xFEAA): 2,
    });
  });

  test('an empty FBP name becomes null', () {
    final result = FbpBleScanner.toBleScanResult(
      ScanResult(
        device: BluetoothDevice(remoteId: const DeviceIdentifier('AA:BB')),
        rssi: -60,
        timeStamp: DateTime(2026),
        advertisementData: AdvertisementData(
          advName: '',
          txPowerLevel: null,
          appearance: null,
          connectable: false,
          manufacturerData: const {},
          serviceData: const {},
          serviceUuids: const [],
        ),
      ),
    );

    expect(result.advertisement.localName, isNull);
  });
}
