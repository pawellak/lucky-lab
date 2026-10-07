import 'company_ids.dart';
import 'scanned_device.dart';

enum ScanSort {
  rssi('Signal'),
  name('Name'),
  firstSeen('First seen');

  const ScanSort(this.label);

  final String label;
}

/// What the user wants to see in the device list.
final class ScanFilter {
  const ScanFilter({
    this.query = '',
    this.minRssi = weakestRssi,
    this.namedOnly = false,
    this.connectableOnly = false,
    this.beaconsOnly = false,
    this.servicesOnly = false,
    this.txPowerOnly = false,
    this.sort = ScanSort.rssi,
  });

  /// The slider's lower end; at this value the RSSI filter is off.
  static const weakestRssi = -100;

  /// Matches name, device id and manufacturer name, ignoring case.
  final String query;
  final int minRssi;
  final bool namedOnly;
  final bool connectableOnly;
  final bool beaconsOnly;

  /// Only devices advertising a service UUID, in the UUID list or as the
  /// key of service data.
  final bool servicesOnly;

  /// Only devices sending the TX Power Level AD structure (0x0A).
  final bool txPowerOnly;
  final ScanSort sort;

  /// Whether anything but the sort order narrows the list.
  bool get isActive =>
      query.isNotEmpty ||
      minRssi > weakestRssi ||
      namedOnly ||
      connectableOnly ||
      beaconsOnly ||
      servicesOnly ||
      txPowerOnly;

  bool matches(ScannedDevice device) {
    if (device.rssi < minRssi) return false;
    if (namedOnly && device.name == null) return false;
    if (connectableOnly && !device.advertisement.connectable) return false;
    if (beaconsOnly && device.payloads.isEmpty) return false;
    if (servicesOnly && !_hasServices(device)) return false;
    if (txPowerOnly && device.advertisement.txPowerLevel == null) return false;
    if (query.isEmpty) return true;

    final needle = query.toLowerCase();
    return [
      device.name ?? '',
      device.id,
      for (final id in device.advertisement.manufacturerData.keys)
        describeCompany(id),
    ].any((text) => text.toLowerCase().contains(needle));
  }

  static bool _hasServices(ScannedDevice device) =>
      device.advertisement.serviceUuids.isNotEmpty ||
      device.advertisement.serviceData.isNotEmpty;

  /// Filters and sorts [devices] for display.
  List<ScannedDevice> apply(Iterable<ScannedDevice> devices) {
    final visible = devices.where(matches).toList();
    return switch (sort) {
      ScanSort.rssi => visible..sort((a, b) => b.rssi.compareTo(a.rssi)),
      ScanSort.name => visible..sort(_byName),
      ScanSort.firstSeen =>
        visible..sort((a, b) => a.firstSeen.compareTo(b.firstSeen)),
    };
  }

  /// Named devices first, alphabetically; unnamed ones by id.
  static int _byName(ScannedDevice a, ScannedDevice b) =>
      switch ((a.name, b.name)) {
        (final x?, final y?) => x.toLowerCase().compareTo(y.toLowerCase()),
        (_?, null) => -1,
        (null, _?) => 1,
        (null, null) => a.id.compareTo(b.id),
      };

  ScanFilter copyWith({
    String? query,
    int? minRssi,
    bool? namedOnly,
    bool? connectableOnly,
    bool? beaconsOnly,
    bool? servicesOnly,
    bool? txPowerOnly,
    ScanSort? sort,
  }) => ScanFilter(
    query: query ?? this.query,
    minRssi: minRssi ?? this.minRssi,
    namedOnly: namedOnly ?? this.namedOnly,
    connectableOnly: connectableOnly ?? this.connectableOnly,
    beaconsOnly: beaconsOnly ?? this.beaconsOnly,
    servicesOnly: servicesOnly ?? this.servicesOnly,
    txPowerOnly: txPowerOnly ?? this.txPowerOnly,
    sort: sort ?? this.sort,
  );
}
