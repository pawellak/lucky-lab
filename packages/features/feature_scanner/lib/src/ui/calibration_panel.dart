import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/calibration_controller.dart';

/// "Calibrate at 1 m": start a run, show its progress, show the result.
class CalibrationPanel extends ConsumerWidget {
  const CalibrationPanel({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(calibrationSessionProvider(deviceId));
    final calibration = ref.watch(
      calibrationsProvider.select((all) => all[deviceId]),
    );
    final controller = ref.read(calibrationSessionProvider(deviceId).notifier);
    final theme = Theme.of(context);
    final hint = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return switch (session) {
      CalibrationMeasuring(:final progress, :final samples) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hold the device 1 m from the phone and keep both still… '
            '$samples packets',
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          TextButton(onPressed: controller.cancel, child: const Text('Cancel')),
        ],
      ),
      CalibrationIdle() || CalibrationFailed() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session case CalibrationFailed(:final message))
            Text(message, style: TextStyle(color: theme.colorScheme.error)),
          if (calibration != null)
            Text(
              'Calibrated: ${calibration.referencePower} dBm at 1 m, the '
              'median of ${calibration.sampleCount} packets '
              '(${calibration.weakest} to ${calibration.strongest} dBm).',
              style: hint,
            )
          else
            Text(
              'The distance uses the power the device claims. Measure it '
              'yourself for this phone instead.',
              style: hint,
            ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: controller.start,
                icon: const Icon(Icons.straighten),
                label: Text(
                  calibration == null ? 'Calibrate at 1 m' : 'Recalibrate',
                ),
              ),
              if (calibration != null)
                TextButton(
                  onPressed: () =>
                      ref.read(calibrationsProvider.notifier).clear(deviceId),
                  child: const Text('Clear'),
                ),
            ],
          ),
        ],
      ),
    };
  }
}
