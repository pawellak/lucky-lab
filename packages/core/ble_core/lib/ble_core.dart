/// Lucky Lab's own abstraction over the underlying BLE library.
///
/// Feature packages talk to BLE only through the interfaces defined here,
/// never to a third-party BLE plugin directly. That keeps the plugin
/// swappable (chapter 7 replaces parts of it with our own native code)
/// and lets tests and the iOS simulator run against a fake implementation.
///
/// Intentionally empty: the first interfaces (adapter state, permissions,
/// scanning) are designed in chapter 1.
library;
