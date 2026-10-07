import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calibration.dart';
import '../domain/scanned_device.dart';
import 'scan_filter_controller.dart';

/// Saved calibrations, keyed by device id.
///
/// Not `autoDispose`: a calibration should survive leaving the device
/// screen. It lives in memory only, and the key is the device id, which on
/// Android changes with the device's private address (~15 min).
final calibrationsProvider =
    NotifierProvider<CalibrationsController, Map<String, RssiCalibration>>(
      CalibrationsController.new,
    );

class CalibrationsController extends Notifier<Map<String, RssiCalibration>> {
  @override
  Map<String, RssiCalibration> build() => const {};

  void save(String deviceId, RssiCalibration calibration) =>
      state = {...state, deviceId: calibration};

  void clear(String deviceId) => state = {...state}..remove(deviceId);
}

/// One calibration run.
sealed class CalibrationSession {
  const CalibrationSession();
}

final class CalibrationIdle extends CalibrationSession {
  const CalibrationIdle();
}

final class CalibrationMeasuring extends CalibrationSession {
  const CalibrationMeasuring({required this.progress, required this.samples});

  /// 0 to 1.
  final double progress;

  /// Packets received since the run started.
  final int samples;
}

final class CalibrationFailed extends CalibrationSession {
  const CalibrationFailed(this.message);

  final String message;
}

/// Runs a calibration for one device: collects its RSSI for [duration],
/// then saves the median to [calibrationsProvider].
///
/// `family`: one controller per device id, passed to the constructor.
final calibrationSessionProvider = NotifierProvider.autoDispose
    .family<CalibrationSessionController, CalibrationSession, String>(
      CalibrationSessionController.new,
    );

class CalibrationSessionController extends Notifier<CalibrationSession> {
  CalibrationSessionController(this.deviceId);

  final String deviceId;

  static const duration = Duration(seconds: 10);
  static const _tick = Duration(milliseconds: 250);

  Timer? _timer;
  DateTime? _startedAt;
  var _ticks = 0;

  @override
  CalibrationSession build() {
    ref.onDispose(() => _timer?.cancel());
    return const CalibrationIdle();
  }

  void start() {
    _timer?.cancel();
    _startedAt = DateTime.now();
    _ticks = 0;
    state = const CalibrationMeasuring(progress: 0, samples: 0);
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    state = const CalibrationIdle();
  }

  void _onTick() {
    _ticks++;
    // Progress counts ticks rather than reading the clock, so widget tests
    // with fake time behave like the real app.
    final progress = (_ticks * _tick.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0);
    final samples = _samplesSinceStart();
    if (progress < 1) {
      state = CalibrationMeasuring(progress: progress, samples: samples.length);
      return;
    }

    _timer?.cancel();
    _timer = null;
    switch (calibrateAt1m(samples)) {
      case final calibration?:
        ref.read(calibrationsProvider.notifier).save(deviceId, calibration);
        state = const CalibrationIdle();
      case null:
        state = CalibrationFailed(
          'Only ${samples.length} packets in ${duration.inSeconds} s; '
          'need $minCalibrationSamples. Is the scan running?',
        );
    }
  }

  List<RssiSample> _samplesSinceStart() {
    final device = ref.read(scannedDeviceProvider(deviceId));
    final startedAt = _startedAt;
    if (device == null || startedAt == null) return const [];
    return [
      for (final sample in device.rssiHistory)
        if (!sample.time.isBefore(startedAt)) sample,
    ];
  }
}
