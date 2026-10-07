import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'offline_sync_chapter.dart';

class OfflineSyncScreen extends StatelessWidget {
  const OfflineSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: offlineSyncChapter);
  }
}
