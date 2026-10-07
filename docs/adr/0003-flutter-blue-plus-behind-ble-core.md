# 3. flutter_blue_plus behind `ble_core`

**Status:** accepted

## Context

Lucky Lab needs a BLE plugin for Android and iOS. The two serious options are
`flutter_blue_plus` (FBP) and `flutter_reactive_ble`.

- FBP is the most widely used and actively developed, and its API is simple
  (async/await plus streams). It is the one I am most likely to meet at work.
- FBP is free for individuals, non-profits and companies under 50 employees.
  Larger companies have to buy a commercial licence.
- `flutter_reactive_ble` is BSD-3 (free for everyone), but it is developed more slowly.

## Decision

Use `flutter_blue_plus`, but only inside `ble_core`. Feature packages depend on
`ble_core`'s own types and interfaces (`BleAdapter`, `BleAdapterState`, …) and never
import FBP.

## Consequences

- The licence is not a lock-in: a company that cannot use FBP can swap the
  implementation behind `ble_core` without touching any feature.
- Chapter 2 replaces parts of FBP with our own Kotlin/Swift plugin through the same interfaces.
- Every FBP type has to be mapped to a `ble_core` type. It is more code, but it
  keeps FBP's enums and exceptions out of the UI.
- A `FakeBleAdapter` can stand in for the real one in tests and on the iOS
  simulator, which has no Bluetooth.
