# Lucky Lab

**by Paweł Lak.** A Flutter app documenting my path from Flutter developer to
**mobile & connected-devices engineer**: 13 hands-on chapters, from BLE advertising
packets to my own energy meter, firmware, edge AI and shipping to the stores. Each
chapter is a separate feature package with its own learning notes. Chapters that need
hardware come with the matching ESP32 / nRF firmware in this repository.

The chapters are grouped by priority and numbered in the recommended learning order.

### Core: what BLE job offers ask for

| # | Chapter | Key topics | Status |
|---|---------|------------|--------|
| 1 | [BLE Scanner & Analyzer](packages/features/feature_scanner) | GAP, advertising format, byte parsing, Android scan limits | In progress |
| 2 | [Native Flutter Plugin](packages/features/feature_plugin_lab) | Chapter 1's scanner in Kotlin + Swift, Pigeon, coroutines / Flow, KMP, Jetpack Compose, pub.dev | Not started |
| 3 | [Energy Meter + Custom GATT](packages/features/feature_energy_meter) | First firmware, GATT design, operation queue, MTU, reconnection | Not started |
| 4 | [OTA Firmware Update](packages/features/feature_ota) | Throughput, DLE, 2M PHY, flow control, MCUboot + SMP | Not started |
| 5 | [Proximity Smart Lock](packages/features/feature_smart_lock) | Bonding, LE Secure Connections, challenge-response, background | Not started |

### Differentiators: what makes you stand out

| # | Chapter | Key topics | Status |
|---|---------|------------|--------|
| 6 | [Reverse Engineering](packages/features/feature_reverse_eng) | nRF Sniffer, Wireshark, HCI snoop logs, UART / SWD | Not started |
| 7 | [Edge AI](packages/features/feature_edge_ai) | On-device anomaly detection (LiteRT), TinyML, LLM tool calling | Not started |
| 8 | [Release & Observability](packages/features/feature_release) | Flavors, Fastlane CI/CD, crash reporting, hardware-in-the-loop tests | Not started |

### Optional

| # | Chapter | Key topics | Status |
|---|---------|------------|--------|
| 9 | [BLE → MQTT Gateway](packages/features/feature_gateway) | Central role on MCU, passive scanning, many connections | Not started |
| 10 | [Offline-First Sync](packages/features/feature_offline_sync) | Drift, sync queue, conflict resolution, background sync | Not started |
| 11 | [Mobile Security](packages/features/feature_security) | OWASP MASVS, secure storage, pinning, obfuscation | Not started |
| 12 | [Widgets, Watch & Live Activities](packages/features/feature_platform_extensions) | WidgetKit, Glance, ActivityKit, Wear OS / watchOS | Not started |
| 13 | [Smart Home & Bluetooth 6.0](packages/features/feature_smart_home) | Matter, Thread, Mesh, direction finding, Channel Sounding, LE Audio | Not started |

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
widget tests, and integration tests on a real phone. Chapter 8 adds
hardware-in-the-loop tests against a real ESP32.

Decisions are recorded in [`docs/adr`](docs/adr).

## Running

```sh
flutter pub get            # once, from the repository root
cd app && flutter run      # BLE needs a physical Android or iOS device
```

No phone at hand, or on the iOS simulator (which has no Bluetooth)? Run with demo
devices instead of the real Bluetooth stack:

```sh
cd app && flutter run --dart-define=FAKE_BLE=true
```

```sh
flutter analyze app packages
(cd app && flutter test)
(cd packages/core/shared && dart test)
(cd packages/core/ble_core && flutter test)
(cd packages/features/feature_scanner && flutter test)
```
