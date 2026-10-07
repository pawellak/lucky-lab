import 'dart:math';

/// A beacon format recognised inside an advertisement.
///
/// `sealed`, so a `switch` over payloads must handle every format and the
/// compiler points at each place to update when a new one is added.
sealed class AdvertisementPayload {
  const AdvertisementPayload();

  /// Short label for list badges, e.g. `iBeacon`.
  String get label;
}

/// Apple iBeacon: manufacturer data from Apple (0x004C) starting `02 15`.
final class IBeaconPayload extends AdvertisementPayload {
  const IBeaconPayload({
    required this.proximityUuid,
    required this.major,
    required this.minor,
    required this.measuredPower,
  });

  final String proximityUuid;
  final int major;
  final int minor;

  /// Expected RSSI at 1 m, in dBm. Used to estimate distance.
  final int measuredPower;

  @override
  String get label => 'iBeacon';
}

/// Eddystone-UID (frame type 0x00): a fixed 16-byte beacon id.
final class EddystoneUidPayload extends AdvertisementPayload {
  const EddystoneUidPayload({
    required this.txPowerAt0m,
    required this.namespace,
    required this.instance,
  });

  /// Calibrated RSSI at 0 m, in dBm. Subtract 41 dB to get the 1 m value.
  final int txPowerAt0m;

  /// 10-byte namespace, as hex.
  final String namespace;

  /// 6-byte instance, as hex.
  final String instance;

  @override
  String get label => 'Eddystone-UID';
}

/// Eddystone-URL (frame type 0x10): a compressed URL.
final class EddystoneUrlPayload extends AdvertisementPayload {
  const EddystoneUrlPayload({required this.txPowerAt0m, required this.url});

  final int txPowerAt0m;
  final String url;

  @override
  String get label => 'Eddystone-URL';
}

/// Eddystone-TLM (frame type 0x20): beacon telemetry.
final class EddystoneTlmPayload extends AdvertisementPayload {
  const EddystoneTlmPayload({
    required this.batteryMillivolts,
    required this.temperatureCelsius,
    required this.advertisingCount,
    required this.uptime,
  });

  /// Null when the beacon reports 0 ("not supported").
  final int? batteryMillivolts;

  /// Null when the beacon reports 0x8000 ("not supported").
  final double? temperatureCelsius;

  /// Packets sent since power-up.
  final int advertisingCount;

  final Duration uptime;

  @override
  String get label => 'Eddystone-TLM';
}

/// Free-space path loss over the first metre at 2.4 GHz, in dB:
/// `20·log10(4π · 1 m / λ)` with λ = 12.5 cm ≈ 40 dB, rounded to the 41
/// the Eddystone spec uses. Turns power at the antenna (0 m) into the RSSI
/// expected at 1 m, and back.
const freeSpaceLossAt1m = 41;

/// Rough distance from signal strength, using the log-distance path loss
/// model: `d = 10 ^ ((P1m - RSSI) / (10 · n))`.
///
/// [measuredPowerAt1m] is the RSSI expected at 1 m. [pathLossExponent] is
/// 2 in free space and 2.5–4 indoors, which is why the result is only a
/// hint: walls, bodies and antenna orientation easily double it.
double estimateDistanceMeters({
  required int rssi,
  required int measuredPowerAt1m,
  double pathLossExponent = 2,
}) => pow(10, (measuredPowerAt1m - rssi) / (10 * pathLossExponent)).toDouble();
