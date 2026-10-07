import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'status_chip.dart';

/// Standard page frame for a chapter screen.
///
/// Until a chapter has real content, pass no [body] and it shows the
/// chapter summary and learning goals. Once it has a [body], the overview
/// moves behind an info button in the app bar.
class ChapterScaffold extends StatelessWidget {
  const ChapterScaffold({
    required this.info,
    this.body,
    this.actions = const [],
    this.floatingActionButton,
    super.key,
  });

  final ChapterInfo info;
  final Widget? body;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final body = this.body;
    return Scaffold(
      appBar: AppBar(
        title: Text('${info.number}. ${info.title}'),
        actions: [
          ...actions,
          if (body != null)
            IconButton(
              tooltip: 'About this chapter',
              icon: const Icon(Icons.info_outline),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _ChapterOverview(info: info, shrinkWrap: true),
              ),
            ),
        ],
      ),
      body: body ?? _ChapterOverview(info: info),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _ChapterOverview extends StatelessWidget {
  const _ChapterOverview({required this.info, this.shrinkWrap = false});

  final ChapterInfo info;

  /// True inside a bottom sheet, so the sheet is only as tall as its content.
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      shrinkWrap: shrinkWrap,
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
