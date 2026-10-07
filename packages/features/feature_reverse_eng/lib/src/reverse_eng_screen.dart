import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'reverse_eng_chapter.dart';

class ReverseEngScreen extends StatelessWidget {
  const ReverseEngScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: reverseEngChapter);
  }
}
