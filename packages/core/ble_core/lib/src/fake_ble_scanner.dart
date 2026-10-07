import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'ble_scan_result.dart';
import 'ble_scanner.dart';
import 'ble_uuid.dart';
import 'latest_value_controller.dart';

/// A pretend peripheral for [FakeBleScanner].
final class FakeBlePeripheral {
  const FakeBlePeripheral({
    required this.id,
    required this.advertisement,
    required this.rssi,
  });

  final String id;
  final BleAdvertisement advertisement;

  /// Typical RSSI; the fake wanders a few dB around it.
  final int rssi;
}

/// In-memory [BleScanner] that "receives" advertisements from a fixed set
/// of peripherals, with a random walk on RSSI. Used by tests and by the
/// app on the iOS simulator (`--dart-define=FAKE_BLE=true`).
final class FakeBleScanner implements BleScanner {
  FakeBleScanner({
    List<FakeBlePeripheral>? peripherals,
    this.interval = const Duration(milliseconds: 150),
    Random? random,
  }) : peripherals = peripherals ?? demoPeripherals,
       _random = random ?? Random();

  final List<FakeBlePeripheral> peripherals;

  /// Time between two fake packets (from any peripheral).
  final Duration interval;

  final Random _random;
  final _results = StreamController<BleScanResult>.broadcast();
  final _isScanning = LatestValueController(false);
  final _rssi = <String, int>{};
  Timer? _timer;

  @override
  Stream<BleScanResult> get results => _results.stream;

  @override
  Stream<bool> get isScanning => _isScanning.stream;

  @override
  Future<void> start() async {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _advertise());
    _isScanning.value = true;
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    if (_isScanning.value) _isScanning.value = false;
  }

  /// Emits one packet now, without waiting for the timer. Handy in tests.
  void advertise(FakeBlePeripheral peripheral, {int? rssi}) {
    _results.add(
      BleScanResult(
        deviceId: peripheral.id,
        rssi: rssi ?? peripheral.rssi,
        timestamp: DateTime.now(),
        advertisement: peripheral.advertisement,
      ),
    );
  }

  void _advertise() {
    final peripheral = peripherals[_random.nextInt(peripherals.length)];
    final previous = _rssi[peripheral.id] ?? peripheral.rssi;
    final rssi = (previous + _random.nextInt(7) - 3).clamp(
      peripheral.rssi - 12,
      peripheral.rssi + 6,
    );
    _rssi[peripheral.id] = rssi;
    advertise(peripheral, rssi: rssi);
  }

  Future<void> dispose() async {
    await stop();
    await _results.close();
    await _isScanning.close();
  }

  static const _meterServiceUuid = '4c75636b-794c-6162-0001-000000000000';

  /// A mix of devices you would meet in an office, with real payload
  /// layouts so the decoders have something to decode.
  static final demoPeripherals = [
    FakeBlePeripheral(
      id: 'C8:2B:96:10:4E:01',
      rssi: -52,
      advertisement: BleAdvertisement(
        localName: 'Lucky Lab Meter',
        txPowerLevel: 0,
        connectable: true,
        serviceUuids: [
          BleUuid.from16(0x181A), // Environmental Sensing
          _meterServiceUuid, // our own service: no short form
        ],
        uuidByteLengths: {BleUuid.from16(0x181A): 2, _meterServiceUuid: 16},
        manufacturerData: {
          0x0059: Uint8List.fromList([0x01, 0x0C, 0xE4, 0x00, 0x7B]), // Nordic
        },
      ),
    ),
    FakeBlePeripheral(
      id: 'F0:12:A7:33:9C:02',
      rssi: -63,
      advertisement: BleAdvertisement(
        manufacturerData: {
          // Apple iBeacon: 02 15 | UUID | major | minor | measured power
          0x004C: Uint8List.fromList([
            0x02, 0x15, //
            0xE2, 0xC5, 0x6D, 0xB5, 0xDF, 0xFB, 0x48, 0xD2, //
            0xB0, 0x60, 0xD0, 0xF5, 0xA7, 0x10, 0x96, 0xE0, //
            0x00, 0x01, 0x00, 0x2A, 0xC5, //
          ]),
        },
      ),
    ),
    FakeBlePeripheral(
      id: 'D4:5E:01:77:21:03',
      rssi: -71,
      advertisement: BleAdvertisement(
        serviceUuids: [BleUuid.from16(0xFEAA)],
        uuidByteLengths: {BleUuid.from16(0xFEAA): 2},
        serviceData: {
          // Eddystone-URL: frame 0x10, tx power -20, "https://" + "lucky-lab" + ".dev"
          BleUuid.from16(0xFEAA): Uint8List.fromList([
            0x10, 0xEC, 0x03, //
            ...'lucky-lab'.codeUnits, 0x2E, 0x64, 0x65, 0x76, //
          ]),
        },
      ),
    ),
    FakeBlePeripheral(
      id: 'D4:5E:01:77:21:04',
      rssi: -74,
      advertisement: BleAdvertisement(
        serviceUuids: [BleUuid.from16(0xFEAA)],
        uuidByteLengths: {BleUuid.from16(0xFEAA): 2},
        serviceData: {
          // Eddystone-TLM: 3012 mV, 23.5 °C, 1200 packets, 3600.0 s up
          BleUuid.from16(0xFEAA): Uint8List.fromList([
            0x20, 0x00, 0x0B, 0xC4, 0x17, 0x80, //
            0x00, 0x00, 0x04, 0xB0, 0x00, 0x00, 0x8C, 0xA0, //
          ]),
        },
      ),
    ),
    FakeBlePeripheral(
      id: 'D4:5E:01:77:21:05',
      rssi: -80,
      advertisement: BleAdvertisement(
        serviceUuids: [BleUuid.from16(0xFEAA)],
        uuidByteLengths: {BleUuid.from16(0xFEAA): 2},
        serviceData: {
          // Eddystone-UID: frame 0x00, tx power -18, namespace + instance
          BleUuid.from16(0xFEAA): Uint8List.fromList([
            0x00, 0xEE, //
            0xED, 0xD1, 0xEB, 0xEA, 0xC0, 0x4E, 0x5D, 0xEF, 0xA0, 0x17, //
            0x00, 0x00, 0x00, 0x00, 0x00, 0x07, //
          ]),
        },
      ),
    ),
    FakeBlePeripheral(
      id: '4A:91:3C:E8:0B:06',
      rssi: -58,
      advertisement: BleAdvertisement(
        connectable: true,
        manufacturerData: {
          0x004C: Uint8List.fromList([
            0x10,
            0x05,
            0x01,
            0x18,
            0x3D,
            0x7A,
            0x22,
          ]),
        },
      ),
    ),
    FakeBlePeripheral(
      id: 'E7:0F:5B:62:A4:07',
      rssi: -86,
      advertisement: BleAdvertisement(
        localName: 'Mi Smart Band 8',
        appearance: 0x00C1, // Watch: sports watch
        connectable: true,
        manufacturerData: {
          0x038F: Uint8List.fromList([0x16, 0x00, 0xA1, 0x07]),
        },
      ),
    ),
  ];
}
