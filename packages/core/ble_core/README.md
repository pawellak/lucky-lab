# ble_core

The app's own interface over the BLE stack. Features depend on this package, never on a
third-party BLE plugin directly ([ADR 0003](../../../docs/adr/0003-flutter-blue-plus-behind-ble-core.md)).

| Type | Role |
|---|---|
| `BleAdapterState` | Whether Bluetooth can be used: `unknown`, `unsupported`, `unauthorized`, `off`, `turningOn`, `turningOff`, `on` |
| `BleAdapter` | Contract: a stream of adapter states that starts with the current one, plus `turnOn` (Android) |
| `BleScanner` | Contract: start/stop a scan, a stream of advertising packets, a stream of "is scanning" |
| `BleScanResult`, `BleAdvertisement` | One received packet and its fields, in our own types |
| `BleException` | Sealed: `BleOperationException`, `BleScanThrottledException` |
| `ScanStartLimiter` | Keeps us under Android's 5 scan starts per 30 s |
| `FbpBleAdapter`, `FbpBleScanner` | Real implementations on top of flutter_blue_plus |
| `FakeBleAdapter`, `FakeBleScanner` | In-memory implementations for tests and the iOS simulator |
| `bleAdapterProvider`, `bleScannerProvider`, `bleAdapterStateProvider` | Riverpod wiring; override them to use the fakes |

## Learning notes

- **State streams replay the current value.** A screen that opens while Bluetooth has
  been off for an hour must show "off" at once, not wait for the next change. FBP does this
  already (`newStreamWithInitialValue`); the fakes do it with `Stream.multi`.
- **Exhaustive `switch` for mapping.** If a future FBP version adds an adapter state, the
  build breaks in `FbpBleAdapter` instead of the new state silently falling through.
- **`unknown` is not an error.** iOS reports it for a moment after start-up, before
  CoreBluetooth answers.
- **Transitional states are Android-only.** iOS jumps straight between `off` and `on`.
- **Plugin exceptions stop here.** `FbpBleScanner` turns `FlutterBluePlusException` into a
  `BleException`, so features `catch` our sealed type and never import FBP.
- **UUIDs are stored long, but sent short.** A 16-bit UUID such as `FEAA` means
  `0000FEAA-0000-1000-8000-00805F9B34FB` (the Bluetooth Base UUID). We always compare the
  128-bit form, and keep the size the platform reported in `uuidByteLengths`, so the device
  screen can show what the packet actually used. A 128-bit UUID takes 16 of the 31 bytes.
