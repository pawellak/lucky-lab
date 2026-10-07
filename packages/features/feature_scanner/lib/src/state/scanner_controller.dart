import 'dart:async';

import 'package:ble_core/ble_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/scanned_device.dart';

/// What the scanner screen shows.
final class ScannerState {
  const ScannerState({
    this.devices = const {},
    this.isScanning = false,
    this.error,
  });

  /// Keyed by [ScannedDevice.id].
  final Map<String, ScannedDevice> devices;
  final bool isScanning;

  /// The last failure, shown once by the screen.
  final BleException? error;

  ScannerState copyWith({
    Map<String, ScannedDevice>? devices,
    bool? isScanning,
    BleException? error,
    bool clearError = false,
  }) => ScannerState(
    devices: devices ?? this.devices,
    isScanning: isScanning ?? this.isScanning,
    error: clearError ? null : error ?? this.error,
  );
}

/// Runs a scan and collects devices.
///
/// `autoDispose`: leaving the scanner screen stops the scan, which matters
/// because scanning is one of the most battery-hungry things an app can do.
final scannerControllerProvider =
    NotifierProvider.autoDispose<ScannerController, ScannerState>(
      ScannerController.new,
    );

class ScannerController extends Notifier<ScannerState> {
  /// A busy room produces hundreds of packets per second. Publishing each
  /// one would rebuild the list hundreds of times per second, so results
  /// are collected in [_devices] and published at most this often.
  static const publishInterval = Duration(milliseconds: 250);

  final _devices = <String, ScannedDevice>{};
  var _dirty = false;
  StreamSubscription<BleScanResult>? _results;
  Timer? _publishTimer;

  BleScanner get _scanner => ref.read(bleScannerProvider);

  @override
  ScannerState build() {
    final scanner = ref.watch(bleScannerProvider);
    final isScanning = scanner.isScanning.listen(
      (scanning) => state = state.copyWith(isScanning: scanning),
    );

    // Bluetooth switched off mid-scan: the OS stops the scan for us, but
    // our subscriptions would otherwise stay open.
    ref.listen(bleAdapterStateProvider, (_, next) {
      if (next.value case final adapter? when !adapter.isReady) {
        unawaited(stop());
      }
    });

    ref.onDispose(() {
      isScanning.cancel();
      _stopCollecting();
      unawaited(scanner.stop());
    });

    _devices.clear();
    return const ScannerState();
  }

  /// Starts a fresh scan; devices from the previous one are cleared.
  Future<void> start() async {
    _devices.clear();
    state = state.copyWith(devices: const {}, clearError: true);

    // Listen first, so no packet is lost between start and listen.
    await _results?.cancel();
    _results = _scanner.results.listen(_onResult, onError: _onError);
    _publishTimer ??= Timer.periodic(publishInterval, (_) => _publish());

    try {
      await _scanner.start();
    } on BleException catch (error) {
      _onError(error);
    }
  }

  Future<void> stop() async {
    _stopCollecting();
    _publish();
    await _scanner.stop();
  }

  void _onResult(BleScanResult result) {
    final known = _devices[result.deviceId];
    _devices[result.deviceId] =
        known?.update(result) ?? ScannedDevice.fromResult(result);
    _dirty = true;
  }

  void _onError(Object error) {
    _stopCollecting();
    if (!ref.mounted) return;
    state = state.copyWith(
      error: error is BleException ? error : BleOperationException('$error'),
    );
  }

  void _publish() {
    if (!_dirty || !ref.mounted) return;
    _dirty = false;
    state = state.copyWith(devices: Map.unmodifiable(_devices));
  }

  void _stopCollecting() {
    unawaited(_results?.cancel());
    _results = null;
    _publishTimer?.cancel();
    _publishTimer = null;
  }
}
