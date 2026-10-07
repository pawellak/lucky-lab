import 'dart:convert';

import 'package:ble_core/ble_core.dart';

import 'scanned_device.dart';

/// Whether a part of the advertising packet reached the app.
enum FieldStatus {
  /// Sent, and the app got it (green).
  received,

  /// Sent (or may be sent), but the radio, the OS or FBP never hands it
  /// to the app (red).
  hidden,

  /// The app could get it, but this device does not send it (purple).
  notSent,
}

/// Device screen cards, so the cheat sheet can say where each part shows.
abstract final class DeviceCards {
  static const signal = 'Signal';
  static const deviceInfo = 'Device info';
  static const pduHeader = 'PDU header';
  static const uuids = 'UUIDs';
  static const payloadBytes = 'Manufacturer & service data';
}

/// One numbered part of a legacy advertising packet, as seen from one
/// device's latest advertisement.
final class PacketField {
  const PacketField({
    required this.number,
    required this.name,
    required this.size,
    required this.description,
    required this.status,
    this.inAdvData = false,
    this.cards = const [],
  });

  final int number;
  final String name;

  /// Bytes on air: exact when the app got the field, a formula otherwise.
  final String size;

  final String description;
  final FieldStatus status;

  /// Whether this is an AD structure inside the 31-byte AdvData.
  final bool inAdvData;

  /// Device screen cards that show this field.
  final List<String> cards;
}

final _macAddress = RegExp(
  r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$',
  caseSensitive: false,
);

/// Whether a device id is a MAC address (Android), not an iOS UUID.
bool isMacAddress(String id) => _macAddress.hasMatch(id);

/// Builds the cheat sheet for [device]: every part of the packet in
/// on-air order, then what the phone measures itself.
///
/// [isIos] matters for fields iOS never reports, so a missing value
/// there is "hidden", not "not sent".
List<PacketField> describePacket(ScannedDevice device, {required bool isIos}) {
  final ad = device.advertisement;

  FieldStatus sentIf(bool present) =>
      present ? FieldStatus.received : FieldStatus.notSent;

  final name = ad.localName;
  final uuidSizes = [
    for (final uuid in ad.serviceUuids) ad.uuidByteLengths[uuid] ?? 16,
  ];

  return [
    const PacketField(
      number: 1,
      name: 'Preamble',
      size: '1 B',
      description:
          '0xAA, alternating bits so the receiver can lock onto the '
          'signal. Used up by the radio chip.',
      status: FieldStatus.hidden,
    ),
    const PacketField(
      number: 2,
      name: 'Access address',
      size: '4 B',
      description:
          '0x8E89BED6, the same for every advertisement in the world. A sync '
          'word, not the device address.',
      status: FieldStatus.hidden,
    ),
    const PacketField(
      number: 3,
      name: 'PDU header',
      size: '2 B',
      description:
          'Packet type (ADV_IND, ADV_NONCONN_IND, …), address type and '
          'length. Only "connectable" reaches the app; the address type '
          '(public or random) is lost.',
      status: FieldStatus.received,
      cards: [DeviceCards.pduHeader, DeviceCards.deviceInfo],
    ),
    PacketField(
      number: 4,
      name: 'AdvA (device address)',
      size: '6 B',
      description: isMacAddress(device.id)
          ? 'The sender\'s address, little-endian on air. Android gives it '
                'to us as the device id.'
          : 'The sender\'s address. iOS hides it and gives a per-phone UUID '
                'instead.',
      status: isMacAddress(device.id)
          ? FieldStatus.received
          : FieldStatus.hidden,
      cards: const [DeviceCards.deviceInfo],
    ),
    const PacketField(
      number: 5,
      name: 'Flags (AD 0x01)',
      size: '3 B',
      description:
          '02 01 06: discoverable, BLE only. Sent by almost every '
          'device, but the OS and FBP drop it.',
      status: FieldStatus.hidden,
      inAdvData: true,
    ),
    PacketField(
      number: 6,
      name: 'Local name (AD 0x08 / 0x09)',
      size: name == null ? '2 + n B' : '${2 + utf8.encode(name).length} B',
      description:
          'Shortened or complete name, 1 byte per ASCII character. Often in '
          'the scan response.',
      status: sentIf(name != null),
      inAdvData: true,
      cards: const [DeviceCards.deviceInfo],
    ),
    PacketField(
      number: 7,
      name: 'TX power (AD 0x0A)',
      size: '3 B',
      description:
          'Transmit power in dBm, signed. Used for the distance estimate.',
      status: sentIf(ad.txPowerLevel != null),
      inAdvData: true,
      cards: const [DeviceCards.deviceInfo, DeviceCards.signal],
    ),
    PacketField(
      number: 8,
      name: 'Appearance (AD 0x19)',
      size: '4 B',
      description:
          'What kind of device it is (watch, keyboard, …). iOS never '
          'reports it.',
      status: ad.appearance != null
          ? FieldStatus.received
          : isIos
          ? FieldStatus.hidden
          : FieldStatus.notSent,
      inAdvData: true,
      cards: const [DeviceCards.deviceInfo],
    ),
    PacketField(
      number: 9,
      name: 'Service UUIDs (AD 0x02–0x07)',
      size: uuidSizes.isEmpty
          ? '2 + n·(2|4|16) B'
          : '${_uuidListBytes(uuidSizes)} B',
      description:
          'Services the device offers: 16-bit for SIG-assigned ones, '
          '128-bit for custom ones.',
      status: sentIf(ad.serviceUuids.isNotEmpty),
      inAdvData: true,
      cards: const [DeviceCards.uuids],
    ),
    PacketField(
      number: 10,
      name: 'Service data (AD 0x16 / 0x20 / 0x21)',
      size: ad.serviceData.isEmpty
          ? '2 + UUID + n B'
          : '${_serviceDataBytes(ad)} B',
      description:
          'A service UUID followed by data, e.g. Eddystone (FEAA). No '
          'connection needed to read it.',
      status: sentIf(ad.serviceData.isNotEmpty),
      inAdvData: true,
      cards: const [DeviceCards.uuids, DeviceCards.payloadBytes],
    ),
    PacketField(
      number: 11,
      name: 'Manufacturer data (AD 0xFF)',
      size: ad.manufacturerData.isEmpty
          ? '4 + n B'
          : '${_manufacturerDataBytes(ad)} B',
      description:
          'A 16-bit company ID (little-endian) followed by the company\'s '
          'own format, e.g. iBeacon.',
      status: sentIf(ad.manufacturerData.isNotEmpty),
      inAdvData: true,
      cards: const [DeviceCards.payloadBytes],
    ),
    const PacketField(
      number: 12,
      name: 'Other AD types',
      size: '2 + n B',
      description:
          'URI, LE role, solicited UUIDs, …. They may be sent, but FBP '
          'does not pass them on.',
      status: FieldStatus.hidden,
      inAdvData: true,
    ),
    const PacketField(
      number: 13,
      name: 'CRC',
      size: '3 B',
      description:
          'Checksum computed by the radio chip. A packet with a bad CRC '
          'is dropped before the OS sees it.',
      status: FieldStatus.hidden,
    ),
    const PacketField(
      number: 14,
      name: 'RSSI and time (not in the packet)',
      size: '—',
      description:
          'Measured by the phone when the packet arrives, not sent by the '
          'device.',
      status: FieldStatus.received,
      cards: [DeviceCards.signal],
    ),
  ];
}

/// UUIDs of the same size share one AD structure: `len | type | uuids…`.
int _uuidListBytes(List<int> sizes) {
  final counts = <int, int>{};
  for (final size in sizes) {
    counts[size] = (counts[size] ?? 0) + 1;
  }
  return counts.entries.fold(0, (sum, e) => sum + 2 + e.key * e.value);
}

/// Each entry is its own AD structure: `len | type | UUID | data`.
int _serviceDataBytes(BleAdvertisement ad) => ad.serviceData.entries.fold(
  0,
  (sum, e) => sum + 2 + (ad.uuidByteLengths[e.key] ?? 16) + e.value.length,
);

/// Each entry is its own AD structure: `len | type | company ID | data`.
int _manufacturerDataBytes(BleAdvertisement ad) =>
    ad.manufacturerData.values.fold(0, (sum, data) => sum + 4 + data.length);
