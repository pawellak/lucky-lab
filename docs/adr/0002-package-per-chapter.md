# 2. One package per chapter, plus shared core packages

**Status:** accepted

## Context

The 13 chapters are independent projects with very different dependencies (charts,
OTA/SMP, crypto, MQTT, a native plugin, a local database, LLM SDKs).

## Decision

A pub workspace with:

- `packages/core/*`: `ble_core`, `design_system` and `shared`, which every chapter can use.
- `packages/features/feature_*`: one package per chapter. Each one exposes a
  `ChapterInfo` (including its priority tier: core, differentiator or optional)
  and a screen.
- `app`: the only package that depends on every feature. It builds the dashboard and
  routes from a single list.

Inside a feature package, layers are folders, not separate packages.

## Consequences

- A chapter's dependencies cannot leak into other chapters.
- Each chapter can be built, tested and reviewed on its own.
- Adding a chapter means one package plus one entry in `app/lib/src/chapters/chapters.dart`.
