import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../domain/scan_filter.dart';
import '../state/scan_filter_controller.dart';

/// Search field plus a button that opens the filter sheet.
class ScanFilterBar extends ConsumerWidget {
  const ScanFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(scanFilterProvider.select((f) => f.isActive));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Name, address or manufacturer',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: ref.read(scanFilterProvider.notifier).setQuery,
            ),
          ),
          IconButton(
            tooltip: 'Filters',
            icon: Badge(
              isLabelVisible: isActive,
              child: const Icon(Icons.tune),
            ),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => const _FilterSheet(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(scanFilterProvider);
    final controller = ref.read(scanFilterProvider.notifier);
    final minRssiLabel = filter.minRssi == ScanFilter.weakestRssi
        ? 'any'
        : formatDbm(filter.minRssi);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text('Sort by', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ScanSort>(
            segments: [
              for (final sort in ScanSort.values)
                ButtonSegment(value: sort, label: Text(sort.label)),
            ],
            selected: {filter.sort},
            onSelectionChanged: (s) => controller.setSort(s.single),
          ),
          const SizedBox(height: 16),
          Text(
            'Minimum signal: $minRssiLabel',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            min: ScanFilter.weakestRssi.toDouble(),
            max: -30,
            divisions: 14,
            value: filter.minRssi.toDouble(),
            label: minRssiLabel,
            onChanged: (v) => controller.setMinRssi(v.round()),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Only devices with a name'),
            value: filter.namedOnly,
            onChanged: controller.setNamedOnly,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Only connectable devices'),
            value: filter.connectableOnly,
            onChanged: controller.setConnectableOnly,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Only beacons'),
            subtitle: const Text('iBeacon and Eddystone'),
            value: filter.beaconsOnly,
            onChanged: controller.setBeaconsOnly,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Only devices with a service UUID'),
            subtitle: const Text('Advertised UUIDs or service data'),
            value: filter.servicesOnly,
            onChanged: controller.setServicesOnly,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Only devices sending TX power'),
            subtitle: const Text(
              'AD type 0x0A, used for the distance estimate',
            ),
            value: filter.txPowerOnly,
            onChanged: controller.setTxPowerOnly,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: filter.isActive ? controller.reset : null,
              child: const Text('Reset filters'),
            ),
          ),
        ],
      ),
    );
  }
}
