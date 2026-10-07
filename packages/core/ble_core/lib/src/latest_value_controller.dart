import 'dart:async';

/// Holds a value and streams it the way [BleAdapter.state] promises:
/// every listener gets the current value first, then each change.
///
/// Internal helper for the fakes; not exported.
final class LatestValueController<T> {
  LatestValueController(this._value);

  T _value;
  final _changes = StreamController<T>.broadcast();

  T get value => _value;

  set value(T value) {
    _value = value;
    _changes.add(value);
  }

  /// Subscribes to the changes in the same step as it adds the current
  /// value, so a change made right after listening cannot be missed.
  Stream<T> get stream => Stream.multi((listener) {
    listener.add(_value);
    final subscription = _changes.stream.listen(listener.add);
    listener.onCancel = subscription.cancel;
  });

  Future<void> close() => _changes.close();
}
