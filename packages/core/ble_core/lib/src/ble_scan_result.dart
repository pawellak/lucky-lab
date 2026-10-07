import 'dart:typed_data';

/// What a peripheral puts in its advertising packets, already split into
/// fields by the OS.
///
/// On air these are AD structures (`length | type | data`); Android and
/// iOS parse them before the app sees them.
final class BleAdvertisement {
  const BleAdvertisement({
    this.localName,
    this.txPowerLevel,
    this.appearance,
    this.connectable = false,
    this.manufacturerData = const {},
    this.serviceData = const {},
    this.serviceUuids = const [],
    this.uuidByteLengths = const {},
  });

  /// Complete or shortened local name (AD types 0x09 / 0x08), if any.
  final String? localName;

  /// Transmit power in dBm (AD type 0x0A), if the peripheral sends it.
  final int? txPowerLevel;

  /// What kind of device this is (AD type 0x19), e.g. `0x00C1` = sports
  /// watch. The top 10 bits are the category. Android only: iOS never
  /// reports it.
  final int? appearance;

  /// Whether the peripheral accepts connections.
  final bool connectable;

  /// Manufacturer specific data (AD type 0xFF), keyed by the 16-bit
  /// company identifier. The bytes exclude the identifier itself.
  final Map<int, Uint8List> manufacturerData;

  /// Service data (AD types 0x16 / 0x20 / 0x21), keyed by 128-bit UUID.
  final Map<String, Uint8List> serviceData;

  /// Advertised service UUIDs, in 128-bit form.
  final List<String> serviceUuids;

  /// How many bytes the platform reported for each UUID in [serviceUuids]
  /// and [serviceData]: 2 (16-bit), 4 (32-bit) or 16 (128-bit). Keyed by
  /// the 128-bit form; missing when the source does not say.
  ///
  /// Short UUIDs save air time: a 16-bit one costs 2 bytes of the 31, a
  /// 128-bit one costs 16.
  final Map<String, int> uuidByteLengths;
}

/// One advertising packet received during a scan.
final class BleScanResult {
  const BleScanResult({
    required this.deviceId,
    required this.rssi,
    required this.timestamp,
    required this.advertisement,
  });

  /// Platform identifier: a MAC address on Android, a per-phone random
  /// UUID on iOS (which never exposes MAC addresses).
  final String deviceId;

  /// Received signal strength in dBm, e.g. -45 (close) to -95 (far).
  final int rssi;

  /// When the phone received this packet.
  final DateTime timestamp;

  final BleAdvertisement advertisement;
}
