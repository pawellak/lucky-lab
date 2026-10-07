/// Lucky Lab's own abstraction over the underlying BLE library.
///
/// Feature packages talk to BLE only through the interfaces defined here,
/// never to a third-party BLE plugin directly. That keeps the plugin
/// swappable (chapter 2 replaces parts of it with our own native code)
/// and lets tests and the iOS simulator run against a fake implementation.
library;

export 'src/ble_adapter.dart';
export 'src/ble_adapter_state.dart';
export 'src/ble_exception.dart';
export 'src/ble_providers.dart';
export 'src/ble_scan_result.dart';
export 'src/ble_scanner.dart';
export 'src/ble_uuid.dart';
export 'src/fake_ble_adapter.dart';
export 'src/fake_ble_scanner.dart';
export 'src/fbp_ble_adapter.dart';
export 'src/fbp_ble_scanner.dart';
export 'src/scan_start_limiter.dart';
