# Chapter 1 – BLE Scanner & Analyzer

Scan nearby devices and decode iBeacon, Eddystone and manufacturer data, with a live RSSI
chart and filters.

## Learning goals

- GAP roles and advertising
- Advertising packet format (AD structures)
- Byte-level parsing of advertising payloads
- Android scan limits and throttling

## What it does

- Shows why scanning is not possible (Bluetooth off, no permission, no BLE) and, on
  Android, turns Bluetooth on.
- Lists devices with signal bars, an RSSI sparkline and tags (connectable, beacon format,
  manufacturer). Devices not heard from for 10 s fade out.
- Search by name, address or manufacturer; filter by minimum RSSI, named, connectable,
  beacons, service UUIDs or TX power only; sort by signal, name or first seen.
- Device screen, top: a **packet cheat sheet**. Every part of an advertising packet is
  numbered and coloured for this device: green = the app got it, red = sent but hidden
  by the radio, OS or FBP, purple = this device does not send it. Each card shows the
  numbers of the parts it displays.
- A **PDU header** card: both header bytes bit by bit (PDU type, RFU, ChSel, TxAdd, RxAdd,
  length). Only "connectable" reaches the app, which narrows the PDU type to two
  candidates; the card also says what kind of random address the device id would be.
- Device screen: RSSI chart for the last 60 s, packet rate, rough distance (optionally
  from your own calibration at 1 m), decoded iBeacon / Eddystone-UID / URL / TLM,
  each UUID with its size in the packet
  (16/32/128-bit) and both forms, and the manufacturer and service data bytes as
  parsed by the OS (FBP never passes the raw AdvData to Dart; see chapter 2).

```
lib/src/
  domain/   pure Dart: decoders, ScannedDevice, ScanFilter (unit-tested with byte fixtures)
  state/    Riverpod: ScannerController, ScanFilterController, derived providers
  ui/       widgets
```

## Learning notes

### GAP roles

GAP (Generic Access Profile) decides who does what before a connection exists:

| Role | Does | Here |
|---|---|---|
| Broadcaster | Advertises, never connects | iBeacon, Eddystone |
| Observer | Scans, never connects | this chapter |
| Peripheral | Advertises, accepts a connection | the energy meter (chapter 3) |
| Central | Scans, opens a connection | the phone from chapter 3 on |

### The advertising packet

An advertisement carries up to 31 bytes (legacy advertising) of **AD structures**:

```
┌────────┬──────┬──────────────────┐
│ length │ type │ data (length-1)  │  × as many as fit in 31 bytes
└────────┴──────┴──────────────────┘
02 01 06                    Flags: LE General Discoverable, BR/EDR not supported
0A 09 4C 75 63 6B 79 ...    Complete Local Name "Lucky…"
1A FF 4C 00 02 15 ...       Manufacturer Specific Data: Apple (4C 00, little-endian) + iBeacon
```

Common types: `0x01` flags, `0x03` 16-bit service UUIDs, `0x09` name, `0x0A` TX power,
`0x16` service data, `0xFF` manufacturer data. A peripheral can send 31 more bytes in a
**scan response** when an active scanner asks, which is why a name sometimes shows up a
moment after the device does.

Android and iOS parse AD structures for us, so `BleAdvertisement` already has fields.
The byte-level work starts inside manufacturer data and service data.

### Payload formats (big-endian, unlike the rest of BLE)

```
iBeacon   (manufacturer data, company 0x004C)
02 15 | proximity UUID (16) | major (2) | minor (2) | measured power @1 m (1, signed)

Eddystone (service data, UUID 0xFEAA), first byte = frame type
00 UID  | tx power @0 m (1, signed) | namespace (10) | instance (6)
10 URL  | tx power @0 m | scheme (1: http://www. https://www. http:// https://) | URL, 0x00–0x0D = .com/ .org/ …
20 TLM  | version 00 | battery mV (2) | temperature 8.8 fixed point (2) | packets (4) | uptime 0.1 s (4)
```

`ByteData.getInt8` / `getUint16` / `getInt16` read these; `ByteData.sublistView` avoids
copying. Every decoder checks the length first: packets come from any device in range, and
a malformed one must not crash the scanner.

### RSSI and distance

`d = 10 ^ ((P1m − RSSI) / (10 · n))`, with `n` = 2 in free space and 2.5–4 indoors.
RSSI jumps by ±5 dB between packets from a device that is not moving, so the distance is
a rough hint ("near / far"), never a measurement.

`P1m` comes from the packet (iBeacon measured power, Eddystone power at 0 m − 41, or the TX
Power Level − 41) or, better, from **Calibrate at 1 m** on the device screen: 10 s of RSSI
with the device held 1 m away, reduced to the **median** (multipath makes some packets
10–20 dB weaker, and a mean would follow those dips). Like calibrating a sound level meter,
it includes this phone's and this device's antennas, so it is valid only for that pair. It
is kept in memory, keyed by device id, which changes with Android private addresses. Chapter 13 covers Channel Sounding,
which actually measures it.

### Android

- **5 scan starts per 30 s.** The sixth start does not fail; Android just returns nothing
  and logs `App is scanning too frequently`. `ScanStartLimiter` refuses the start and the
  UI says when to retry.
- **Scans longer than 30 minutes** are downgraded to opportunistic (almost no results).
- **`neverForLocation` hides beacons.** Declaring `BLUETOOTH_SCAN` with it avoids the
  location permission on Android 12+, but Android then drops iBeacon/Eddystone packets.
  So we ask for `ACCESS_FINE_LOCATION`, and location services must be on.
- Device ids are MAC addresses, but most phones and many devices use **resolvable private
  addresses** that change every ~15 minutes, so the same device can show up twice.

### iOS

- **No MAC addresses.** The id is a UUID that CoreBluetooth generates per phone.
- **iBeacon is invisible to CoreBluetooth.** iOS strips Apple's iBeacon packets from scan
  results; apps must use CoreLocation region ranging with known UUIDs instead. The iBeacon
  decoder works on Android (and in the fake).
- Without `allowDuplicates` iOS reports each device once per scan; FBP's
  `continuousUpdates` turns it on so the RSSI chart keeps moving (foreground only).
- The simulator has no Bluetooth: run with `--dart-define=FAKE_BLE=true`.

### Flutter / Riverpod

- **Batch the UI updates.** A busy office produces hundreds of packets per second.
  `ScannerController` collects them in a plain map and publishes state every 250 ms.
- **`autoDispose` stops the scan** when you leave the screen; scanning costs battery.
- **Derived providers** (`visibleDevicesProvider`, `scannedDeviceProvider` with `family`
  and `select`) keep filtering out of widgets and limit rebuilds to what changed.
- **Errors are events.** The screen shows them with `ref.listen` + a snackbar, not as part
  of the widget tree.
- **Sealed classes.** `AdvertisementPayload` and `BleException` are sealed, so every
  `switch` must handle each case, and adding a format breaks the build where the UI needs it.

## Status

In progress. Done in code and tests (decoders, filters, controller, widget tests on the
fake). Still to do: test on a real Android phone and iPhone, then mark the chapter done.
