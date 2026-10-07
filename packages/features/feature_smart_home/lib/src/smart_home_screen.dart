import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'smart_home_chapter.dart';

class SmartHomeScreen extends StatelessWidget {
  const SmartHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: smartHomeChapter);
  }
}
