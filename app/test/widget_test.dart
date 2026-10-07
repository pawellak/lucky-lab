import 'package:lucky_lab/src/lucky_lab_app.dart';
import 'package:lucky_lab/src/chapters/chapters.dart';
import 'package:lucky_lab/src/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chapters are numbered 1..13 with unique slugs', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final chapters = container.read(chaptersProvider);

    expect(
      chapters.map((c) => c.info.number).toList()..sort(),
      List.generate(13, (i) => i + 1),
    );
    expect(chapters.map((c) => c.info.slug).toSet(), hasLength(13));
  });

  testWidgets('dashboard opens a chapter and goes back', (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: LuckyLabApp()));

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('BLE Scanner & Analyzer'), findsOneWidget);
    expect(find.text('Release & Observability'), findsOneWidget);

    await tester.tap(find.text('Proximity Smart Lock'));
    await tester.pumpAndSettle();

    expect(find.text('5. Proximity Smart Lock'), findsOneWidget);
    expect(find.text('LE Secure Connections'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
