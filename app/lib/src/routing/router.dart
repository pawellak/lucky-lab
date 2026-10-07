import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../chapters/chapters.dart';
import '../dashboard/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final chapters = ref.watch(chaptersProvider);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const DashboardScreen(),
        routes: [
          for (final chapter in chapters)
            GoRoute(
              path: chapter.info.slug,
              builder: (context, _) => chapter.builder(context),
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
