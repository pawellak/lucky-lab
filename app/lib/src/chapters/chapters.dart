import 'package:feature_edge_ai/feature_edge_ai.dart';
import 'package:feature_energy_meter/feature_energy_meter.dart';
import 'package:feature_gateway/feature_gateway.dart';
import 'package:feature_offline_sync/feature_offline_sync.dart';
import 'package:feature_ota/feature_ota.dart';
import 'package:feature_platform_extensions/feature_platform_extensions.dart';
import 'package:feature_plugin_lab/feature_plugin_lab.dart';
import 'package:feature_release/feature_release.dart';
import 'package:feature_reverse_eng/feature_reverse_eng.dart';
import 'package:feature_scanner/feature_scanner.dart';
import 'package:feature_security/feature_security.dart';
import 'package:feature_smart_home/feature_smart_home.dart';
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

/// All chapters in recommended learning order. The dashboard groups them
/// by [ChapterInfo.tier] and keeps this order within each tier.
final chaptersProvider = Provider<List<AppChapter>>(
  (ref) => [
    // Core
    AppChapter(
      info: scannerChapter,
      icon: Icons.radar,
      builder: (_) => const ScannerScreen(),
    ),
    AppChapter(
      info: pluginLabChapter,
      icon: Icons.extension,
      builder: (_) => const PluginLabScreen(),
    ),
    AppChapter(
      info: energyMeterChapter,
      icon: Icons.bolt,
      builder: (_) => const EnergyMeterScreen(),
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
    // Differentiators
    AppChapter(
      info: reverseEngChapter,
      icon: Icons.manage_search,
      builder: (_) => const ReverseEngScreen(),
    ),
    AppChapter(
      info: edgeAiChapter,
      icon: Icons.psychology,
      builder: (_) => const EdgeAiScreen(),
    ),
    AppChapter(
      info: releaseChapter,
      icon: Icons.rocket_launch,
      builder: (_) => const ReleaseScreen(),
    ),
    // Optional
    AppChapter(
      info: gatewayChapter,
      icon: Icons.router,
      builder: (_) => const GatewayScreen(),
    ),
    AppChapter(
      info: offlineSyncChapter,
      icon: Icons.cloud_sync,
      builder: (_) => const OfflineSyncScreen(),
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
      info: smartHomeChapter,
      icon: Icons.home_work,
      builder: (_) => const SmartHomeScreen(),
    ),
  ],
);
