import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'plugin_lab_chapter.dart';

class PluginLabScreen extends StatelessWidget {
  const PluginLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: pluginLabChapter);
  }
}
