import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'ai_assistant_chapter.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: aiAssistantChapter);
  }
}
