import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'scanner_chapter.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: scannerChapter);
  }
}
