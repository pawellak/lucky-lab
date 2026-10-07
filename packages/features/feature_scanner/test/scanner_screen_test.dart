import 'package:ble_core/ble_core.dart';
import 'package:feature_scanner/feature_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeBleAdapter adapter;
  late FakeBleScanner scanner;

  setUp(() {
    adapter = FakeBleAdapter();
    scanner = FakeBleScanner(interval: const Duration(milliseconds: 20));
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 16000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bleAdapterProvider.overrideWithValue(adapter),
          bleScannerProvider.overrideWithValue(scanner),
        ],
        child: const MaterialApp(home: ScannerScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('scans, lists devices and opens one', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Tap Scan to look for nearby devices.'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Lucky Lab Meter'), findsOneWidget);
    expect(find.textContaining('devices'), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await tester.pump();

    await tester.tap(find.text('Lucky Lab Meter'));
    await tester.pumpAndSettle();
    expect(find.text('Signal'), findsOneWidget);
    expect(find.text('Manufacturer & service data'), findsOneWidget);
    expect(find.text('Packet cheat sheet'), findsOneWidget);
    expect(find.text('PDU header'), findsOneWidget);
    expect(find.text('Device info'), findsOneWidget);
    expect(find.textContaining('0000 ADV_IND'), findsOneWidget);
    expect(find.text('UUIDs'), findsOneWidget);
    expect(find.text('Service · 2 bytes (16-bit)'), findsOneWidget);
    expect(find.text('Service · 16 bytes (128-bit)'), findsOneWidget);

    await tester.tap(find.text('What each number means'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Preamble ·'), findsOneWidget);
  });

  Future<void> openMeter(WidgetTester tester) async {
    await tester.tap(find.text('Lucky Lab Meter'));
    // The scan keeps running, so pumpAndSettle would never settle: one
    // frame to push the route, then let the transition finish.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('calibrates at 1 m while scanning and uses it for distance', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Scan'));
    await tester.pump(const Duration(seconds: 2));
    await openMeter(tester);

    expect(find.textContaining('from device data'), findsOneWidget);

    await tester.tap(find.text('Calibrate at 1 m'));
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.textContaining('Calibrated:'), findsOneWidget);
    expect(find.textContaining('from your calibration'), findsOneWidget);
    // The meter declares 0 dBm; the fake's RSSI around -52 at "1 m" gives
    // about -11 dBm, so it reads as below the declared value.
    expect(find.text('Measured TX power'), findsOneWidget);
    expect(find.textContaining('below the declared 0 dBm'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pump();
    expect(find.textContaining('from device data'), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Stop'));
    await tester.pump();
  });

  testWidgets('calibration fails without packets', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Scan'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Stop'));
    await tester.pump();
    await openMeter(tester);

    await tester.tap(find.text('Calibrate at 1 m'));
    await tester.pump(const Duration(seconds: 11));

    expect(find.textContaining('Only 0 packets'), findsOneWidget);
  });

  testWidgets('explains when Bluetooth is off and offers to turn it on', (
    tester,
  ) async {
    adapter.emit(BleAdapterState.off);
    await pumpScreen(tester);

    expect(find.text('Bluetooth is off.'), findsOneWidget);

    await tester.tap(find.text('Turn on'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Bluetooth is off.'), findsNothing);
  });
}
