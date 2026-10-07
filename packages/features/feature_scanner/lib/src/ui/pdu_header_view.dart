import 'package:flutter/material.dart';

import '../domain/pdu_header.dart';
import 'packet_cheat_sheet.dart';

/// The PDU header as two coloured bytes, most significant bit on the left,
/// then what each sub-field holds.
class PduHeaderView extends StatelessWidget {
  const PduHeaderView({required this.fields, super.key});

  final List<PduHeaderBits> fields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Drawn MSB first, as a byte is usually written: bit 7 on the left.
    List<PduHeaderBits> byte(int index) =>
        fields.where((f) => f.byte == index).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final index in [0, 1]) ...[
          Text(
            'Byte $index  (bit 7 … bit 0)',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              for (final field in byte(index))
                Expanded(flex: field.width, child: _BitsBox(field)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        for (final field in fields) _BitsRow(field),
        const SizedBox(height: 4),
        Text(
          'On air the header follows the access address; the radio and the '
          'Bluetooth stack read it, and FBP passes on only "connectable".',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _BitsBox extends StatelessWidget {
  const _BitsBox(this.field);

  final PduHeaderBits field;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fieldStatusColor(field.status),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '${field.name}\n${field.bits}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}

class _BitsRow extends StatelessWidget {
  const _BitsRow(this.field);

  final PduHeaderBits field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 10,
              height: 10,
              color: fieldStatusColor(field.status),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${field.name} · byte ${field.byte}, bits ${field.bits}',
                  style: theme.textTheme.labelLarge,
                ),
                SelectableText(
                  field.value,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
                Text(field.description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
