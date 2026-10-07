import 'package:ble_core/ble_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explains why scanning is not possible, with a fix where there is one.
/// Shows nothing while Bluetooth is ready.
class AdapterStateBanner extends ConsumerWidget {
  const AdapterStateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adapter = ref.watch(bleAdapterProvider);

    return switch (ref.watch(bleAdapterStateProvider)) {
      AsyncError(:final error) => _Banner(
        icon: Icons.error_outline,
        message: 'Could not read the Bluetooth state: $error',
        isError: true,
      ),
      AsyncData(:final value) => switch (value) {
        BleAdapterState.on => const SizedBox.shrink(),
        BleAdapterState.unknown => const _Banner(
          icon: Icons.hourglass_empty,
          message: 'Checking Bluetooth…',
        ),
        BleAdapterState.unsupported => const _Banner(
          icon: Icons.bluetooth_disabled,
          message:
              'This device has no Bluetooth LE. On the iOS simulator, '
              'run with --dart-define=FAKE_BLE=true for demo devices.',
          isError: true,
        ),
        BleAdapterState.unauthorized => const _Banner(
          icon: Icons.lock_outline,
          message:
              'Lucky Lab is not allowed to use Bluetooth. Allow it in '
              'Settings → Privacy & Security → Bluetooth.',
          isError: true,
        ),
        BleAdapterState.off => _Banner(
          icon: Icons.bluetooth_disabled,
          message: 'Bluetooth is off.',
          action: adapter.canTurnOn
              ? TextButton(
                  onPressed: () => adapter.turnOn().catchError((_) {}),
                  child: const Text('Turn on'),
                )
              : null,
        ),
        BleAdapterState.turningOn => const _Banner(
          icon: Icons.bluetooth_searching,
          message: 'Bluetooth is turning on…',
        ),
        BleAdapterState.turningOff => const _Banner(
          icon: Icons.bluetooth_disabled,
          message: 'Bluetooth is turning off…',
        ),
      },
      AsyncLoading() => const _Banner(
        icon: Icons.hourglass_empty,
        message: 'Checking Bluetooth…',
      ),
    };
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.message,
    this.action,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final Widget? action;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = isError
        ? colors.onErrorContainer
        : colors.onSecondaryContainer;
    return Material(
      color: isError ? colors.errorContainer : colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
