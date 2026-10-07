import 'package:flutter/material.dart';

import '../domain/packet_field.dart';

/// Green: the app got it. Red: sent, but hidden from the app. Purple: this
/// device does not send it.
Color fieldStatusColor(FieldStatus status) => switch (status) {
  FieldStatus.received => Colors.green.shade700,
  FieldStatus.hidden => Colors.red.shade700,
  FieldStatus.notSent => Colors.purple.shade600,
};

/// The packet's parts as numbered, coloured boxes in on-air order, then
/// a legend and what each number means and which card shows it.
class PacketCheatSheet extends StatelessWidget {
  const PacketCheatSheet({required this.fields, super.key});

  final List<PacketField> fields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final before = fields.where((f) => !f.inAdvData && f.number < 5);
    final advData = fields.where((f) => f.inAdvData);
    final after = fields.where((f) => !f.inAdvData && f.number >= 5);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Packet cheat sheet', style: theme.textTheme.titleMedium),
                Text(
                  'One legacy advertising packet, on-air order',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final field in before) _FieldBox(field),
                    _AdvDataGroup(fields: advData.toList()),
                    for (final field in after) _FieldBox(field),
                  ],
                ),
                const SizedBox(height: 12),
                const _Legend(),
              ],
            ),
          ),
          // The descriptions are long; folded so the live data stays near
          // the top of the screen.
          ExpansionTile(
            title: const Text('What each number means'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final field in fields) _FieldRow(field),
              const SizedBox(height: 4),
              Text(
                'With a scan response the phone gets a second packet with 31 '
                'more bytes of AdvData; the OS merges both.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small coloured circle with a field's number, also used on card titles.
class FieldNumberBadge extends StatelessWidget {
  const FieldNumberBadge(this.field, {super.key});

  final PacketField field;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 11,
      backgroundColor: fieldStatusColor(field.status),
      child: Text(
        '${field.number}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox(this.field);

  final PacketField field;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: fieldStatusColor(field.status),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${field.number} ${field.name.split(' (').first}\n${field.size}',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _AdvDataGroup extends StatelessWidget {
  const _AdvDataGroup({required this.fields});

  final List<PacketField> fields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AdvData ≤ 31 B', style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [for (final field in fields) _FieldBox(field)],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _LegendItem(FieldStatus.received, 'received'),
        _LegendItem(FieldStatus.hidden, 'sent, hidden from the app'),
        _LegendItem(FieldStatus.notSent, 'not sent by this device'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.status, this.label);

  final FieldStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: fieldStatusColor(status)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow(this.field);

  final PacketField field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldNumberBadge(field),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${field.name} · ${field.size}',
                  style: theme.textTheme.labelLarge,
                ),
                Text(field.description, style: theme.textTheme.bodySmall),
                Text(
                  field.cards.isEmpty
                      ? 'Not shown: the app never gets it.'
                      : '→ ${field.cards.join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
