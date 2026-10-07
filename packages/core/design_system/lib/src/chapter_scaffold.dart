import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'status_chip.dart';

/// Standard page frame for a chapter screen.
///
/// Until a chapter has real content, pass no [body] and it shows the
/// chapter summary and learning goals.
class ChapterScaffold extends StatelessWidget {
  const ChapterScaffold({required this.info, this.body, super.key});

  final ChapterInfo info;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${info.number}. ${info.title}')),
      body: body ?? _ChapterOverview(info: info),
    );
  }
}

class _ChapterOverview extends StatelessWidget {
  const _ChapterOverview({required this.info});

  final ChapterInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusChip(status: info.status),
            if (info.needsHardware)
              const Chip(
                avatar: Icon(Icons.memory, size: 16),
                label: Text('Needs hardware'),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(info.summary, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        Text('What you will learn', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final goal in info.learningGoals)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(goal),
          ),
        if (info.bonusGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Bonus', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final goal in info.bonusGoals)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.star_outline),
              title: Text(goal),
            ),
        ],
      ],
    );
  }
}
