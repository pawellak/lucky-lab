import 'package:ble_core/ble_core.dart';
import 'package:feature_scanner/src/state/scan_filter_controller.dart';
import 'package:feature_scanner/src/state/scanner_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A scanner whose start always fails, like Android does without permission.
final class _FailingScanner implements BleScanner {
  @override
  Stream<BleScanResult> get results => const Stream.empty();

  @override
  Stream<bool> get isScanning => Stream.value(false);

  @override
  Future<void> start() async =>
      throw const BleOperationException('Permission denied');

  @override
  Future<void> stop() async {}
}

void main() {
  late FakeBleAdapter adapter;
  late FakeBleScanner scanner;
  late ProviderContainer container;

  ProviderContainer createContainer(BleScanner scanner) =>
      ProviderContainer.test(
        overrides: [
          bleAdapterProvider.overrideWithValue(adapter),
          bleScannerProvider.overrideWithValue(scanner),
        ],
      );

  setUp(() {
    adapter = FakeBleAdapter();
    // A long interval: the tests push packets with advertise() themselves.
    scanner = FakeBleScanner(interval: const Duration(hours: 1));
    container = createContainer(scanner);
    // Keep the auto-dispose providers alive for the whole test.
    container.listen(scannerControllerProvider, (_, _) {});
    container.listen(visibleDevicesProvider, (_, _) {});
  });

  tearDown(() async {
    await scanner.dispose();
    await adapter.dispose();
  });

  Future<void> waitForPublish() =>
      Future<void>.delayed(ScannerController.publishInterval * 2);

  test('collects packets into devices, published in batches', () async {
    final controller = container.read(scannerControllerProvider.notifier);
    await controller.start();
    final [meter, beacon, ...] = FakeBleScanner.demoPeripherals;

    scanner
      ..advertise(meter, rssi: -50)
      ..advertise(meter, rssi: -55)
      ..advertise(beacon, rssi: -70);
    // Nothing yet: the batch is published on the next tick.
    expect(container.read(scannerControllerProvider).devices, isEmpty);

    await waitForPublish();

    final state = container.read(scannerControllerProvider);
    expect(state.isScanning, isTrue);
    expect(state.devices, hasLength(2));
    expect(state.devices[meter.id]!.packetCount, 2);
    expect(state.devices[meter.id]!.rssi, -55);
  });

  test('applies the filter to the visible devices', () async {
    await container.read(scannerControllerProvider.notifier).start();
    for (final peripheral in FakeBleScanner.demoPeripherals) {
      scanner.advertise(peripheral);
    }
    await waitForPublish();

    container.read(scanFilterProvider.notifier).setNamedOnly(true);

    expect(container.read(visibleDevicesProvider).map((d) => d.name), [
      'Lucky Lab Meter',
      'Mi Smart Band 8',
    ]);
  });

  test('stops scanning when Bluetooth turns off', () async {
    await container.read(scannerControllerProvider.notifier).start();
    await waitForPublish();

    adapter.emit(BleAdapterState.off);
    await waitForPublish();

    expect(container.read(scannerControllerProvider).isScanning, isFalse);
  });

  test('reports a failed start as an error', () async {
    final container = createContainer(_FailingScanner());
    container.listen(scannerControllerProvider, (_, _) {});

    await container.read(scannerControllerProvider.notifier).start();

    expect(
      container.read(scannerControllerProvider).error?.message,
      'Permission denied',
    );
  });
}
