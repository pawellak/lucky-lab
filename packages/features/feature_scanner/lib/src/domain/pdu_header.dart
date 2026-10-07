import 'packet_field.dart';
import 'scanned_device.dart';

/// One sub-field of the 2-byte PDU header of a legacy advertising packet.
final class PduHeaderBits {
  const PduHeaderBits({
    required this.name,
    required this.byte,
    required this.bits,
    required this.width,
    required this.value,
    required this.description,
    required this.status,
  });

  final String name;

  /// 0 or 1.
  final int byte;

  /// Bit positions within [byte], e.g. `0–3`.
  final String bits;

  /// Number of bits, for drawing.
  final int width;

  /// What the app knows about the value.
  final String value;
  final String description;
  final FieldStatus status;
}

/// What the top two bits of a *random* address mean, or null when [id] is
/// not a MAC address (iOS).
///
/// The first octet in `F0:12:…` is the most significant one, the last on
/// air. A public address can have any bits there, so this says what the
/// address would be *if* it is random; only TxAdd could tell.
String? randomAddressKind(String id) {
  if (!isMacAddress(id)) return null;
  final top = int.parse(id.substring(0, 2), radix: 16) >> 6;
  return switch (top) {
    0x3 => 'static (top bits 11)',
    0x1 => 'resolvable private, changes every ~15 min (top bits 01)',
    0x0 => 'non-resolvable private (top bits 00)',
    _ => 'reserved (top bits 10), so probably a public address',
  };
}

/// The PDU header's sub-fields in on-air order, with what reached the app.
///
/// FBP passes only "connectable", which narrows the PDU type down to two
/// candidates. Everything else stops in the Bluetooth stack.
List<PduHeaderBits> describePduHeader(ScannedDevice device) {
  final connectable = device.advertisement.connectable;
  final addressKind = randomAddressKind(device.id);

  return [
    PduHeaderBits(
      name: 'PDU type',
      byte: 0,
      bits: '0–3',
      width: 4,
      value: connectable
          ? '0000 ADV_IND (or 0001 ADV_DIRECT_IND)'
          : '0010 ADV_NONCONN_IND or 0110 ADV_SCAN_IND',
      description:
          'Whether the device accepts connections and answers scan '
          'requests. FBP only says "connectable", so two types remain.',
      status: FieldStatus.received,
    ),
    const PduHeaderBits(
      name: 'RFU',
      byte: 0,
      bits: '4',
      width: 1,
      value: 'always 0',
      description: 'Reserved for future use.',
      status: FieldStatus.hidden,
    ),
    const PduHeaderBits(
      name: 'ChSel',
      byte: 0,
      bits: '5',
      width: 1,
      value: 'not reported',
      description:
          'Whether the device supports channel selection algorithm #2 '
          '(BLE 5) for a later connection.',
      status: FieldStatus.hidden,
    ),
    PduHeaderBits(
      name: 'TxAdd',
      byte: 0,
      bits: '6',
      width: 1,
      value: addressKind == null
          ? 'not reported'
          : 'not reported; if random: $addressKind',
      description:
          'Address type of AdvA: 0 = public (from the IEEE, fixed), '
          '1 = random. Android knows it but FBP does not pass it on.',
      status: FieldStatus.hidden,
    ),
    const PduHeaderBits(
      name: 'RxAdd',
      byte: 0,
      bits: '7',
      width: 1,
      value: 'not reported',
      description:
          'Address type of the target, only used by ADV_DIRECT_IND '
          '(an advertisement addressed to one central).',
      status: FieldStatus.hidden,
    ),
    const PduHeaderBits(
      name: 'Length',
      byte: 1,
      bits: '0–7',
      width: 8,
      value: 'not reported',
      description:
          'Payload length: AdvA (6) + AdvData (0–31), so 6–37. The OS '
          'merges the scan response in, so it cannot be worked out either.',
      status: FieldStatus.hidden,
    ),
  ];
}
