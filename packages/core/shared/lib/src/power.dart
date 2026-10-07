import 'dart:math';

/// Converts dBm (dB relative to 1 mW) to milliwatts: `P = 10^(dBm / 10)`.
double dbmToMilliwatts(int dbm) => pow(10, dbm / 10).toDouble();

const _units = [
  ('W', 1e3),
  ('mW', 1.0),
  ('µW', 1e-3),
  ('nW', 1e-6),
  ('pW', 1e-9),
  ('fW', 1e-12),
];

/// Formats a power level with its linear value in the closest unit, to
/// three significant digits: `12 dBm (15.8 mW)`, `-48 dBm (15.8 nW)`.
String formatDbm(int dbm) {
  final milliwatts = dbmToMilliwatts(dbm);
  final (unit, scale) = _units.firstWhere(
    (u) => milliwatts >= u.$2,
    orElse: () => _units.last,
  );
  final value = (milliwatts / scale).toStringAsPrecision(3);
  // `1.00` → `1`, `2.50` → `2.5`; integer dBm never lands near 999.5.
  final trimmed = value.contains('.')
      ? value.replaceFirst(RegExp(r'\.?0+$'), '')
      : value;
  return '$dbm dBm ($trimmed $unit)';
}
