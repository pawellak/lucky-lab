import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'advanced_chapter.dart';

class AdvancedScreen extends StatelessWidget {
  const AdvancedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: advancedChapter);
  }
}
