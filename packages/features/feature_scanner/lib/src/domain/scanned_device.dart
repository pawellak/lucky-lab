import 'package:ble_core/ble_core.dart';

import 'advertisement_decoder.dart';
import 'advertisement_payload.dart';

/// One RSSI reading, for the chart.
final class RssiSample {
  const RssiSample(this.time, this.rssi);

  final DateTime time;
  final int rssi;
}

/// Everything known about one peripheral, built up from its advertisements.
///
/// Immutable: [update] returns a new instance, so Riverpod can tell that
/// something changed.
final class ScannedDevice {
  ScannedDevice._({
    required this.id,
    required this.advertisement,
    required this.rssi,
    required this.firstSeen,
    required this.lastSeen,
    required this.packetCount,
    required this.rssiHistory,
  });

  factory ScannedDevice.fromResult(BleScanResult result) => ScannedDevice._(
    id: result.deviceId,
    advertisement: result.advertisement,
    rssi: result.rssi,
    firstSeen: result.timestamp,
    lastSeen: result.timestamp,
    packetCount: 1,
    rssiHistory: [RssiSample(result.timestamp, result.rssi)],
  );

  /// How much RSSI history to keep for the chart.
  static const historyWindow = Duration(seconds: 60);

  final String id;

  /// The latest advertisement. Some devices alternate between packets
  /// (e.g. Eddystone URL and TLM), so this can change from one to the next.
  final BleAdvertisement advertisement;

  final int rssi;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final int packetCount;

  /// Oldest first, covering at most [historyWindow].
  final List<RssiSample> rssiHistory;

  /// Beacon formats found in the latest advertisement.
  late final List<AdvertisementPayload> payloads = AdvertisementDecoder.decode(
    advertisement,
  );

  String? get name => advertisement.localName;

  ScannedDevice update(BleScanResult result) {
    final cutoff = result.timestamp.subtract(historyWindow);
    return ScannedDevice._(
      id: id,
      // Keep the last known name: scan responses carrying it can be
      // separate packets from the ones carrying beacon data.
      advertisement: result.advertisement.localName != null || name == null
          ? result.advertisement
          : BleAdvertisement(
              localName: name,
              txPowerLevel: result.advertisement.txPowerLevel,
              appearance: result.advertisement.appearance,
              connectable: result.advertisement.connectable,
              manufacturerData: result.advertisement.manufacturerData,
              serviceData: result.advertisement.serviceData,
              serviceUuids: result.advertisement.serviceUuids,
              uuidByteLengths: result.advertisement.uuidByteLengths,
            ),
      rssi: result.rssi,
      firstSeen: firstSeen,
      lastSeen: result.timestamp,
      packetCount: packetCount + 1,
      rssiHistory: [
        ...rssiHistory.where((s) => s.time.isAfter(cutoff)),
        RssiSample(result.timestamp, result.rssi),
      ],
    );
  }

  /// Advertising rate over the RSSI history window.
  double get packetsPerSecond {
    if (rssiHistory.length < 2) return 0;
    final span = rssiHistory.last.time.difference(rssiHistory.first.time);
    if (span == Duration.zero) return 0;
    return (rssiHistory.length - 1) / (span.inMilliseconds / 1000);
  }

  /// Measured power at 1 m from a beacon payload or the TX power field,
  /// or null if the device does not say how strong it transmits.
  int? get measuredPowerAt1m {
    for (final payload in payloads) {
      switch (payload) {
        case IBeaconPayload(:final measuredPower):
          return measuredPower;
        case EddystoneUidPayload(:final txPowerAt0m) ||
            EddystoneUrlPayload(:final txPowerAt0m):
          return txPowerAt0m - freeSpaceLossAt1m;
        case EddystoneTlmPayload():
          break;
      }
    }
    // The TX Power Level field is the power at the antenna (0 m).
    return switch (advertisement.txPowerLevel) {
      final tx? => tx - freeSpaceLossAt1m,
      null => null,
    };
  }

  double? get estimatedDistanceMeters => switch (measuredPowerAt1m) {
    final power? => estimateDistanceMeters(
      rssi: rssi,
      measuredPowerAt1m: power,
    ),
    null => null,
  };
}
