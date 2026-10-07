import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'platform_extensions_chapter.dart';

class PlatformExtensionsScreen extends StatelessWidget {
  const PlatformExtensionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: platformExtensionsChapter);
  }
}
