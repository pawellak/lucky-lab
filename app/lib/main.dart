import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/lucky_lab_app.dart';

void main() {
  runApp(const ProviderScope(child: LuckyLabApp()));
}
