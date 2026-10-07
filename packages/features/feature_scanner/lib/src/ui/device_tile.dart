import 'package:flutter/material.dart';

import '../domain/company_ids.dart';
import '../domain/scanned_device.dart';
import 'rssi_badge.dart';
import 'rssi_chart.dart';

/// A device in the scan list.
class DeviceTile extends StatelessWidget {
  const DeviceTile({required this.device, required this.onTap, super.key});

  /// A device not heard from for this long is shown faded.
  static const staleAfter = Duration(seconds: 10);

  final ScannedDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStale = DateTime.now().difference(device.lastSeen) > staleAfter;
    final tags = [
      for (final payload in device.payloads) payload.label,
      for (final id in device.advertisement.manufacturerData.keys)
        companyNames[id] ?? describeCompany(id),
    ];

    return Opacity(
      opacity: isStale ? 0.5 : 1,
      child: ListTile(
        onTap: onTap,
        leading: RssiBadge(rssi: device.rssi),
        title: Text(
          device.name ?? 'Unknown device',
          style: device.name == null
              ? const TextStyle(fontStyle: FontStyle.italic)
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.id, style: theme.textTheme.bodySmall),
            if (tags.isNotEmpty || device.advertisement.connectable)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (device.advertisement.connectable)
                      const _Tag(icon: Icons.link, label: 'Connectable'),
                    for (final tag in tags.toSet()) _Tag(label: tag),
                  ],
                ),
              ),
          ],
        ),
        trailing: SizedBox(
          width: 64,
          height: 32,
          child: RssiChart(samples: device.rssiHistory, compact: true),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon case final icon?) ...[
              Icon(icon, size: 12),
              const SizedBox(width: 2),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
