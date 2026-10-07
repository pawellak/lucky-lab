import 'package:ble_core/ble_core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scanner_chapter.dart';
import 'state/scan_filter_controller.dart';
import 'state/scanner_controller.dart';
import 'ui/adapter_state_banner.dart';
import 'ui/device_detail_screen.dart';
import 'ui/device_tile.dart';
import 'ui/scan_filter_bar.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Errors are events, not screen state: show each one once.
    ref.listen(scannerControllerProvider.select((s) => s.error), (_, error) {
      if (error == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    });

    final isReady = ref.watch(
      bleAdapterStateProvider.select((s) => s.value?.isReady ?? false),
    );
    final isScanning = ref.watch(
      scannerControllerProvider.select((s) => s.isScanning),
    );
    final controller = ref.read(scannerControllerProvider.notifier);

    return ChapterScaffold(
      info: scannerChapter,
      body: const Column(
        children: [
          AdapterStateBanner(),
          ScanFilterBar(),
          Expanded(child: _DeviceList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: !isReady
            ? null
            : isScanning
            ? controller.stop
            : controller.start,
        backgroundColor: isReady
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        icon: Icon(isScanning ? Icons.stop : Icons.radar),
        label: Text(isScanning ? 'Stop' : 'Scan'),
      ),
    );
  }
}

class _DeviceList extends ConsumerWidget {
  const _DeviceList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(visibleDevicesProvider);
    final total = ref.watch(
      scannerControllerProvider.select((s) => s.devices.length),
    );
    final isScanning = ref.watch(
      scannerControllerProvider.select((s) => s.isScanning),
    );

    if (devices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(switch ((total, isScanning)) {
            (0, false) => 'Tap Scan to look for nearby devices.',
            (0, true) => 'Looking for devices…',
            _ => 'No devices match the filters ($total hidden).',
          }, textAlign: TextAlign.center),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(
                total == devices.length
                    ? '$total devices'
                    : '${devices.length} of $total devices',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              if (isScanning)
                const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            // Room for the floating button over the last tile.
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceTile(
                key: ValueKey(device.id),
                device: device,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DeviceDetailScreen(deviceId: device.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
