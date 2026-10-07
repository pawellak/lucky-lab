import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'release_chapter.dart';

class ReleaseScreen extends StatelessWidget {
  const ReleaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: releaseChapter);
  }
}
