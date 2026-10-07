import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'status_chip.dart';

/// Dashboard tile for one chapter.
class ChapterCard extends StatelessWidget {
  const ChapterCard({
    required this.info,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final ChapterInfo info;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: Icon(icon, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    '${info.number}'.padLeft(2, '0'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                info.title,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  info.summary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 8),
              StatusChip(status: info.status),
            ],
          ),
        ),
      ),
    );
  }
}
