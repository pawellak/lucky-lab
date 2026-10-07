import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_exception.dart';
import 'ble_scan_result.dart';
import 'ble_scanner.dart';
import 'scan_start_limiter.dart';

/// [BleScanner] backed by flutter_blue_plus.
final class FbpBleScanner implements BleScanner {
  FbpBleScanner({ScanStartLimiter? limiter})
    : _limiter = limiter ?? ScanStartLimiter();

  final ScanStartLimiter _limiter;

  @override
  Stream<BleScanResult> get results => FlutterBluePlus.onScanResults
      .expand((batch) => batch)
      .map(toBleScanResult)
      .transform(
        StreamTransformer.fromHandlers(
          handleError: (error, stackTrace, sink) =>
              sink.addError(_toBleException(error), stackTrace),
        ),
      );

  @override
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  @override
  Future<void> start() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _limiter.recordStart();
    }
    try {
      await FlutterBluePlus.startScan(
        // One event per packet, and repeated packets from the same device,
        // so RSSI can be charted over time.
        oneByOne: true,
        continuousUpdates: true,
        // `neverForLocation` would make Android drop beacon packets, so we
        // declare fine location on Android 12+ as well (see the manifest).
        androidUsesFineLocation: true,
      );
    } on Object catch (error) {
      throw _toBleException(error);
    }
  }

  @override
  Future<void> stop() => FlutterBluePlus.stopScan();

  static Object _toBleException(Object error) => switch (error) {
    BleException() => error,
    FlutterBluePlusException(:final description, :final function) =>
      BleOperationException(description ?? '$function failed'),
    _ => BleOperationException('$error'),
  };

  /// Maps FBP's scan result to ours.
  static BleScanResult toBleScanResult(ScanResult result) {
    final ad = result.advertisementData;
    return BleScanResult(
      deviceId: result.device.remoteId.str,
      rssi: result.rssi,
      timestamp: result.timeStamp,
      advertisement: BleAdvertisement(
        localName: ad.advName.isEmpty ? null : ad.advName,
        txPowerLevel: ad.txPowerLevel,
        appearance: ad.appearance,
        connectable: ad.connectable,
        manufacturerData: {
          for (final MapEntry(:key, :value) in ad.manufacturerData.entries)
            key: Uint8List.fromList(value),
        },
        serviceData: {
          for (final MapEntry(:key, :value) in ad.serviceData.entries)
            key.str128: Uint8List.fromList(value),
        },
        serviceUuids: [for (final uuid in ad.serviceUuids) uuid.str128],
        uuidByteLengths: {
          for (final uuid in [...ad.serviceUuids, ...ad.serviceData.keys])
            uuid.str128: uuid.bytes.length,
        },
      ),
    );
  }
}
