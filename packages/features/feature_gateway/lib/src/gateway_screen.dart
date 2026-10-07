import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'gateway_chapter.dart';

class GatewayScreen extends StatelessWidget {
  const GatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChapterScaffold(info: gatewayChapter);
  }
}
