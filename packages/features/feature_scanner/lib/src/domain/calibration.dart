import 'advertisement_payload.dart';
import 'scanned_device.dart';

/// The RSSI this phone reads from one device held 1 m away: the `P_1m` of
/// the distance formula, measured instead of taken from the packet.
///
/// Like calibrating a sound level meter with an acoustic calibrator: the
/// phone's antenna, the device's antenna and case are all in the number.
/// It is only valid for this phone, this device and roughly this
/// orientation.
final class RssiCalibration {
  const RssiCalibration({
    required this.referencePower,
    required this.sampleCount,
    required this.weakest,
    required this.strongest,
  });

  /// Median RSSI at 1 m, in dBm.
  final int referencePower;
  final int sampleCount;
  final int weakest;
  final int strongest;

  /// The TX power that would give [referencePower] at 1 m in free space:
  /// the declared TX power's formula run backwards.
  ///
  /// An *effective* value, not what the chip puts out: both antennas, the
  /// case and any hand in between are included. Comparing it with the
  /// declared TX power shows how much of the claim reaches this phone.
  int get measuredTxPower => referencePower + freeSpaceLossAt1m;
}

/// Packets needed for a usable median; fewer means the device advertises
/// too rarely or the scan was not running.
const minCalibrationSamples = 5;

/// Reduces RSSI readings taken at 1 m to one reference value, or null if
/// there are fewer than [minCalibrationSamples].
///
/// The median, not the mean: multipath makes some packets 10–20 dB weaker,
/// and a few such dips would drag a mean down.
RssiCalibration? calibrateAt1m(List<RssiSample> samples) {
  if (samples.length < minCalibrationSamples) return null;
  final rssi = [for (final s in samples) s.rssi]..sort();
  final middle = rssi.length ~/ 2;
  final median = rssi.length.isOdd
      ? rssi[middle]
      : ((rssi[middle - 1] + rssi[middle]) / 2).round();
  return RssiCalibration(
    referencePower: median,
    sampleCount: rssi.length,
    weakest: rssi.first,
    strongest: rssi.last,
  );
}
