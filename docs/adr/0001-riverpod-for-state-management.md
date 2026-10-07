# 1. Riverpod for state management

**Status:** accepted

## Context

BLE work is mostly about streams (scan results, adapter and connection state,
characteristic notifications) and resources with a lifecycle (subscriptions,
connections). I already know Bloc well.

## Decision

Use Riverpod 3 (`flutter_riverpod`) with plain, hand-written providers. No code
generation for now.

## Consequences

- `StreamProvider` / `AsyncNotifier` map directly onto BLE streams.
- `ref.onDispose` gives each provider one place to cancel subscriptions and disconnect.
- Provider overrides let tests and the iOS simulator run against a fake `ble_core`.
- Writing providers by hand first makes it clear what each provider type does.
  Switching to `riverpod_generator` later is a mechanical change.
