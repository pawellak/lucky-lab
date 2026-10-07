import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/scan_filter.dart';
import '../domain/scanned_device.dart';
import 'scanner_controller.dart';

final scanFilterProvider =
    NotifierProvider.autoDispose<ScanFilterController, ScanFilter>(
      ScanFilterController.new,
    );

class ScanFilterController extends Notifier<ScanFilter> {
  @override
  ScanFilter build() => const ScanFilter();

  void setQuery(String query) => state = state.copyWith(query: query.trim());

  void setMinRssi(int minRssi) => state = state.copyWith(minRssi: minRssi);

  void setNamedOnly(bool value) => state = state.copyWith(namedOnly: value);

  void setConnectableOnly(bool value) =>
      state = state.copyWith(connectableOnly: value);

  void setBeaconsOnly(bool value) => state = state.copyWith(beaconsOnly: value);

  void setServicesOnly(bool value) =>
      state = state.copyWith(servicesOnly: value);

  void setTxPowerOnly(bool value) => state = state.copyWith(txPowerOnly: value);

  void setSort(ScanSort sort) => state = state.copyWith(sort: sort);

  /// Clears filters but keeps the search text and sort order.
  void reset() => state = ScanFilter(query: state.query, sort: state.sort);
}

/// The device list after filtering and sorting.
///
/// A derived provider: it recomputes only when the devices or the filter
/// change, and widgets never filter by themselves.
final visibleDevicesProvider = Provider.autoDispose<List<ScannedDevice>>((ref) {
  final devices = ref.watch(scannerControllerProvider.select((s) => s.devices));
  return ref.watch(scanFilterProvider).apply(devices.values);
});

/// One device, for the detail screen. `family` creates one provider per
/// device id; `select` rebuilds the screen only when that device changes.
final scannedDeviceProvider = Provider.autoDispose
    .family<ScannedDevice?, String>(
      (ref, id) =>
          ref.watch(scannerControllerProvider.select((s) => s.devices[id])),
    );
