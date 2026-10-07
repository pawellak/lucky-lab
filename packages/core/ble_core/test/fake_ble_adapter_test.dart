import 'package:ble_core/ble_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeBleAdapter adapter;

  setUp(() => adapter = FakeBleAdapter(BleAdapterState.off));
  tearDown(() => adapter.dispose());

  test('a new listener gets the current state first', () {
    expect(adapter.state, emits(BleAdapterState.off));
  });

  test('a listener gets every change after the current state', () {
    expectLater(
      adapter.state,
      emitsInOrder([
        BleAdapterState.off,
        BleAdapterState.turningOn,
        BleAdapterState.on,
      ]),
    );

    adapter
      ..emit(BleAdapterState.turningOn)
      ..emit(BleAdapterState.on);
  });

  test('a late listener starts from the latest state', () async {
    adapter.emit(BleAdapterState.on);

    expect(await adapter.state.first, BleAdapterState.on);
  });
}
