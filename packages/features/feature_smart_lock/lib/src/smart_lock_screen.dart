import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'smart_lock_chapter.dart';

class SmartLockScreen extends StatelessWidget {
  const SmartLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: smartLockChapter);
  }
}
