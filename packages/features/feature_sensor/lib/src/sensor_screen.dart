import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'sensor_chapter.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: sensorChapter);
  }
}
