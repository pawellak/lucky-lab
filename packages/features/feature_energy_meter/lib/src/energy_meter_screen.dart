import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'energy_meter_chapter.dart';

class EnergyMeterScreen extends StatelessWidget {
  const EnergyMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: energyMeterChapter);
  }
}
