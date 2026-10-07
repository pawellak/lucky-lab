import 'package:feature_advanced/feature_advanced.dart';
import 'package:feature_ai_assistant/feature_ai_assistant.dart';
import 'package:feature_gateway/feature_gateway.dart';
import 'package:feature_matter/feature_matter.dart';
import 'package:feature_offline_sync/feature_offline_sync.dart';
import 'package:feature_ota/feature_ota.dart';
import 'package:feature_platform_extensions/feature_platform_extensions.dart';
import 'package:feature_plugin_lab/feature_plugin_lab.dart';
import 'package:feature_release/feature_release.dart';
import 'package:feature_reverse_eng/feature_reverse_eng.dart';
import 'package:feature_scanner/feature_scanner.dart';
import 'package:feature_security/feature_security.dart';
import 'package:feature_sensor/feature_sensor.dart';
import 'package:feature_smart_lock/feature_smart_lock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

/// A chapter as the app shell sees it: its description, dashboard icon
/// and the screen it opens.
///
/// This is the only place that knows about every feature package.
class AppChapter {
  const AppChapter({
    required this.info,
    required this.icon,
    required this.builder,
  });

  final ChapterInfo info;
  final IconData icon;
  final WidgetBuilder builder;
}

final chaptersProvider = Provider<List<AppChapter>>(
  (ref) => [
    // BLE & IoT
    AppChapter(
      info: scannerChapter,
      icon: Icons.radar,
      builder: (_) => const ScannerScreen(),
    ),
    AppChapter(
      info: sensorChapter,
      icon: Icons.thermostat,
      builder: (_) => const SensorScreen(),
    ),
    AppChapter(
      info: otaChapter,
      icon: Icons.system_update_alt,
      builder: (_) => const OtaScreen(),
    ),
    AppChapter(
      info: smartLockChapter,
      icon: Icons.lock_open,
      builder: (_) => const SmartLockScreen(),
    ),
    AppChapter(
      info: reverseEngChapter,
      icon: Icons.manage_search,
      builder: (_) => const ReverseEngScreen(),
    ),
    AppChapter(
      info: gatewayChapter,
      icon: Icons.router,
      builder: (_) => const GatewayScreen(),
    ),
    AppChapter(
      info: pluginLabChapter,
      icon: Icons.extension,
      builder: (_) => const PluginLabScreen(),
    ),
    AppChapter(
      info: advancedChapter,
      icon: Icons.auto_awesome,
      builder: (_) => const AdvancedScreen(),
    ),
    // Production skills
    AppChapter(
      info: offlineSyncChapter,
      icon: Icons.cloud_sync,
      builder: (_) => const OfflineSyncScreen(),
    ),
    AppChapter(
      info: aiAssistantChapter,
      icon: Icons.smart_toy,
      builder: (_) => const AiAssistantScreen(),
    ),
    AppChapter(
      info: securityChapter,
      icon: Icons.shield,
      builder: (_) => const SecurityScreen(),
    ),
    AppChapter(
      info: platformExtensionsChapter,
      icon: Icons.watch,
      builder: (_) => const PlatformExtensionsScreen(),
    ),
    AppChapter(
      info: releaseChapter,
      icon: Icons.rocket_launch,
      builder: (_) => const ReleaseScreen(),
    ),
    // BLE & IoT, added later
    AppChapter(
      info: matterChapter,
      icon: Icons.home_work,
      builder: (_) => const MatterScreen(),
    ),
  ],
);
