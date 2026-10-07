import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final ChapterStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      ChapterStatus.notStarted => (
        'Not started',
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
      ChapterStatus.inProgress => (
        'In progress',
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      ChapterStatus.done => (
        'Done',
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
