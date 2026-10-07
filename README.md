# Lucky Lab

**by Paweł Lak.** A Flutter app documenting my path from Flutter developer to
**mobile & connected-devices engineer**: 14 hands-on chapters, from BLE advertising
packets to firmware, security and shipping to the stores. Each chapter is a separate
feature package with its own learning notes. Chapters that need hardware come with
the matching ESP32 / nRF firmware in this repository.

### BLE & IoT

| # | Chapter | Key topics | Status |
|---|---------|------------|--------|
| 1 | [BLE Scanner & Analyzer](packages/features/feature_scanner) | GAP, advertising format, byte parsing, Android scan limits | Not started |
| 2 | [Sensor + Custom GATT](packages/features/feature_sensor) | GATT design, operation queue, MTU, reconnection | Not started |
| 3 | [OTA Firmware Update](packages/features/feature_ota) | Throughput, DLE, 2M PHY, flow control, MCUboot + SMP | Not started |
| 4 | [Proximity Smart Lock](packages/features/feature_smart_lock) | Bonding, LE Secure Connections, challenge-response, background | Not started |
| 5 | [Reverse Engineering](packages/features/feature_reverse_eng) | nRF Sniffer, Wireshark, HCI snoop logs | Not started |
| 6 | [BLE → MQTT Gateway](packages/features/feature_gateway) | Central role on MCU, passive scanning, many connections | Not started |
| 7 | [Native Flutter Plugin](packages/features/feature_plugin_lab) | CoreBluetooth, android.bluetooth, Pigeon, Kotlin Multiplatform | Not started |
| 8 | [Bluetooth 5.x / 6.0](packages/features/feature_advanced) | Mesh, direction finding, Channel Sounding, LE Audio | Not started |
| 14 | [Matter & Thread](packages/features/feature_matter) | BLE commissioning, clusters, Thread, esp-matter | Not started |

### Production skills

| # | Chapter | Key topics | Status |
|---|---------|------------|--------|
| 9 | [Offline-First Sync](packages/features/feature_offline_sync) | Drift, sync queue, conflict resolution, background sync | Not started |
| 10 | [AI Device Assistant](packages/features/feature_ai_assistant) | LLM tool calling, MCP, on-device ML | Not started |
| 11 | [Mobile Security](packages/features/feature_security) | OWASP MASVS, secure storage, pinning, obfuscation | Not started |
| 12 | [Widgets, Watch & Live Activities](packages/features/feature_platform_extensions) | WidgetKit, Glance, ActivityKit, Wear OS / watchOS | Not started |
| 13 | [Release & Observability](packages/features/feature_release) | Flavors, Fastlane CI/CD, crash reporting, hardware-in-the-loop tests | Not started |

## Architecture

A [Dart pub workspace](https://dart.dev/tools/pub/workspaces) monorepo:

```
app/                      thin shell: dashboard, routing (go_router), wiring (Riverpod)
packages/
  core/
    ble_core/             the app's own BLE interface; features never touch a BLE plugin directly
    design_system/        theme and shared widgets
    shared/               pure-Dart models and utilities
  features/
    feature_<chapter>/    one package per chapter
firmware/                 ESP32 / nRF firmware for the hardware chapters
docs/adr/                 architecture decision records
```

Dependency rules:

- `app` → features → core. Never the other way round.
- Feature packages never import each other.
- `shared` stays free of Flutter so protocol code can be tested with plain `dart test`.

Every chapter ships with tests: unit tests for protocol code, a fake `ble_core` for
widget tests, and integration tests on a real phone. Chapter 13 adds
hardware-in-the-loop tests against a real ESP32.

Decisions are recorded in [`docs/adr`](docs/adr).

## Running

```sh
flutter pub get            # once, from the repository root
cd app && flutter run      # BLE needs a physical Android or iOS device
```

```sh
flutter analyze app packages
(cd app && flutter test)
(cd packages/core/shared && dart test)
```
