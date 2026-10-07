import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'edge_ai_chapter.dart';

class EdgeAiScreen extends StatelessWidget {
  const EdgeAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: edgeAiChapter);
  }
}
