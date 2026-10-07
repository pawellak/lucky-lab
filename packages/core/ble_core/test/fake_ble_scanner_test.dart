import 'package:ble_core/ble_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeBleScanner scanner;

  setUp(
    () => scanner = FakeBleScanner(interval: const Duration(milliseconds: 5)),
  );
  tearDown(() => scanner.dispose());

  test('reports scanning state, starting with the current one', () async {
    expect(await scanner.isScanning.first, isFalse);

    await scanner.start();
    expect(await scanner.isScanning.first, isTrue);

    await scanner.stop();
    expect(await scanner.isScanning.first, isFalse);
  });

  test('emits advertisements from demo peripherals while scanning', () async {
    final ids = FakeBleScanner.demoPeripherals.map((p) => p.id).toSet();
    final results = scanner.results.take(3).toList();

    await scanner.start();

    for (final result in await results) {
      expect(ids, contains(result.deviceId));
    }
  });
}
