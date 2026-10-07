import 'package:flutter/material.dart';

/// Signal bars plus the RSSI value.
class RssiBadge extends StatelessWidget {
  const RssiBadge({required this.rssi, super.key});

  final int rssi;

  @override
  Widget build(BuildContext context) {
    // Rough bands; RSSI depends a lot on the phone and the antenna.
    final icon = switch (rssi) {
      >= -60 => Icons.signal_cellular_alt,
      >= -75 => Icons.signal_cellular_alt_2_bar,
      _ => Icons.signal_cellular_alt_1_bar,
    };
    return SizedBox(
      width: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          Text('$rssi', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
