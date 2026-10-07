import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'matter_chapter.dart';

class MatterScreen extends StatelessWidget {
  const MatterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: matterChapter);
  }
}
