import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'ota_chapter.dart';

class OtaScreen extends StatelessWidget {
  const OtaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: otaChapter);
  }
}
