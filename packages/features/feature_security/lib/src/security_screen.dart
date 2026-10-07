import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'security_chapter.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: securityChapter);
  }
}
