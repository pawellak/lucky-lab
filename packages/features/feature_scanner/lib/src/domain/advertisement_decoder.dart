import 'dart:typed_data';

import 'package:ble_core/ble_core.dart';
import 'package:shared/shared.dart';

import 'advertisement_payload.dart';

/// Recognises beacon formats in an advertisement.
///
/// Every decoder checks lengths before reading, because advertisements come
/// from any device nearby and a malformed one must not crash the scanner.
abstract final class AdvertisementDecoder {
  static const appleCompanyId = 0x004C;
  static final eddystoneServiceUuid = BleUuid.from16(0xFEAA);

  static List<AdvertisementPayload> decode(BleAdvertisement ad) => [
    if (ad.manufacturerData[appleCompanyId] case final data?)
      ?decodeIBeacon(data),
    if (ad.serviceData[eddystoneServiceUuid] case final data?)
      ?decodeEddystone(data),
  ];

  /// iBeacon, after the company id (23 bytes):
  ///
  /// ```text
  /// 02 15 | proximity UUID (16) | major (2, BE) | minor (2, BE) | power (1, signed)
  /// ```
  ///
  /// `02` is Apple's type "iBeacon" and `15` (21) the length of the rest.
  static IBeaconPayload? decodeIBeacon(Uint8List data) {
    if (data.length != 23 || data[0] != 0x02 || data[1] != 0x15) return null;
    final bytes = ByteData.sublistView(data);
    final uuid = toHex(data.sublist(2, 18), separator: '');
    return IBeaconPayload(
      proximityUuid:
          '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-'
          '${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-'
          '${uuid.substring(20)}',
      major: bytes.getUint16(18), // BLE is little-endian, iBeacon is not.
      minor: bytes.getUint16(20),
      measuredPower: bytes.getInt8(22),
    );
  }

  /// Eddystone service data: the first byte is the frame type.
  static AdvertisementPayload? decodeEddystone(Uint8List data) {
    if (data.isEmpty) return null;
    return switch (data[0]) {
      0x00 => _decodeUid(data),
      0x10 => _decodeUrl(data),
      0x20 => _decodeTlm(data),
      _ => null, // EID (0x30) and future frames are not decoded.
    };
  }

  /// `00 | tx power (1, signed) | namespace (10) | instance (6) | RFU (2)?`
  static EddystoneUidPayload? _decodeUid(Uint8List data) {
    if (data.length < 18) return null;
    return EddystoneUidPayload(
      txPowerAt0m: ByteData.sublistView(data).getInt8(1),
      namespace: toHex(data.sublist(2, 12), separator: ''),
      instance: toHex(data.sublist(12, 18), separator: ''),
    );
  }

  static const _urlSchemes = [
    'http://www.',
    'https://www.',
    'http://',
    'https://',
  ];

  /// Bytes 0x00–0x0D stand for common URL parts, to fit in 17 bytes.
  static const _urlExpansions = [
    '.com/', '.org/', '.edu/', '.net/', '.info/', '.biz/', '.gov/', //
    '.com', '.org', '.edu', '.net', '.info', '.biz', '.gov', //
  ];

  /// `10 | tx power (1, signed) | scheme (1) | encoded URL (≤17)`
  static EddystoneUrlPayload? _decodeUrl(Uint8List data) {
    if (data.length < 3 || data[2] >= _urlSchemes.length) return null;
    final url = StringBuffer(_urlSchemes[data[2]]);
    for (final byte in data.skip(3)) {
      if (byte < _urlExpansions.length) {
        url.write(_urlExpansions[byte]);
      } else if (byte > 0x20 && byte < 0x7F) {
        url.writeCharCode(byte);
      } else {
        return null;
      }
    }
    return EddystoneUrlPayload(
      txPowerAt0m: ByteData.sublistView(data).getInt8(1),
      url: url.toString(),
    );
  }

  /// Unencrypted TLM, all big-endian:
  ///
  /// ```text
  /// 20 | version 00 | battery mV (2) | temp 8.8 fixed point (2)
  ///    | packets sent (4) | uptime in 0.1 s (4)
  /// ```
  static EddystoneTlmPayload? _decodeTlm(Uint8List data) {
    if (data.length != 14 || data[1] != 0x00) return null;
    final bytes = ByteData.sublistView(data);
    final battery = bytes.getUint16(2);
    final temperature = bytes.getInt16(4);
    return EddystoneTlmPayload(
      batteryMillivolts: battery == 0 ? null : battery,
      // 8.8 fixed point: high byte is whole degrees, low byte 1/256ths.
      temperatureCelsius: temperature == -0x8000 ? null : temperature / 256,
      advertisingCount: bytes.getUint32(6),
      uptime: Duration(milliseconds: bytes.getUint32(10) * 100),
    );
  }
}
