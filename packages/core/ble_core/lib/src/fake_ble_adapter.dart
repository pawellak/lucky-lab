import 'ble_adapter.dart';
import 'ble_adapter_state.dart';
import 'latest_value_controller.dart';

/// In-memory [BleAdapter] for tests and the iOS simulator, which has no
/// Bluetooth. Call [emit] to simulate the user toggling Bluetooth.
final class FakeBleAdapter implements BleAdapter {
  FakeBleAdapter([BleAdapterState initial = BleAdapterState.on])
    : _state = LatestValueController(initial);

  final LatestValueController<BleAdapterState> _state;

  /// The state a new listener would receive first.
  BleAdapterState get current => _state.value;

  @override
  Stream<BleAdapterState> get state => _state.stream;

  @override
  bool get canTurnOn => true;

  @override
  Future<void> turnOn() async => emit(BleAdapterState.on);

  /// Sets a new state and pushes it to every listener.
  void emit(BleAdapterState state) => _state.value = state;

  /// Closes the stream of changes. Call it in test tear-down.
  Future<void> dispose() => _state.close();
}
