import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:password_manager/features/sync/application/sync_status_provider.dart';
import 'package:password_manager/features/sync/domain/connected_device.dart';
import 'package:password_manager/features/sync/domain/i_sync_service.dart';
import 'package:password_manager/features/sync/presentation/pairing_screen.dart';
import 'package:password_manager/features/sync/presentation/widgets/sync_summary_card.dart';
import 'package:password_manager/l10n/app_localizations.dart';
import 'package:password_manager/theme/app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../support/fake_sync_service.dart';

/// Widget tests for the desktop/mobile pairing views. They resolve the fake via
/// `getIt<ISyncService>()` (registered in setUp) and drive state transitions by
/// pushing events on the fake's streams — never `pumpAndSettle` (there are
/// AnimatedSwitchers and async initState work), just bumped frames.
void main() {
  late FakeSyncService fake;

  setUp(() {
    fake = FakeSyncService();
    GetIt.I.registerSingleton<ISyncService>(fake);
  });

  tearDown(() async {
    await GetIt.I.reset();
    await fake.dispose();
  });

  // ResponsiveLayout.isDesktop is `MediaQuery.width > 720`, so the physical size
  // (at dpr 1.0) selects the desktop vs mobile view.
  const desktopSize = Size(1100, 820);
  const mobileSize = Size(400, 820);

  Future<void> pumpPairing(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // SyncSummaryCard reads syncStatusProvider → syncEventsSourceProvider,
          // which by default hits getIt<SyncService>() (unregistered here).
          syncEventsSourceProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PairingScreen(),
        ),
      ),
    );
  }

  // Resolves the async initState work (checkPairingKey / auto-start / autoResume)
  // and any AnimatedSwitcher (200ms) without pumpAndSettle.
  Future<void> flush(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 260));
  }

  group('desktop view', () {
    testWidgets('auto-starts the server and shows the pairing QR',
        (tester) async {
      await pumpPairing(tester, size: desktopSize);
      await flush(tester);

      expect(fake.startServerCalls, 1);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the connected panel with the live device list',
        (tester) async {
      fake.serverRunning = true; // already running → skip auto-start
      fake.hasPairingKeyResult = true;
      fake.devices = const [
        ConnectedDevice(
            id: 'a', name: 'Pixel 7', status: DeviceSyncStatus.connected),
        ConnectedDevice(
            id: 'b', name: 'Galaxy S24', status: DeviceSyncStatus.syncing),
        ConnectedDevice(
            id: 'c', name: 'iPhone 15', status: DeviceSyncStatus.synced),
      ];

      await pumpPairing(tester, size: desktopSize);
      await flush(tester);

      expect(fake.startServerCalls, 0);
      expect(find.text('Pixel 7'), findsOneWidget);
      expect(find.text('Galaxy S24'), findsOneWidget);
      expect(find.text('iPhone 15'), findsOneWidget);
      expect(find.byType(SyncSummaryCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the Sync-now button asks the connected phones and reports it',
        (tester) async {
      fake.serverRunning = true;
      fake.hasPairingKeyResult = true;
      fake.devices = const [
        ConnectedDevice(
            id: 'a', name: 'Pixel 7', status: DeviceSyncStatus.connected),
        ConnectedDevice(
            id: 'b', name: 'Galaxy S24', status: DeviceSyncStatus.connected),
      ];
      fake.requestSyncFromDevicesResult = 2;

      await pumpPairing(tester, size: desktopSize);
      await flush(tester);

      await tester.ensureVisible(find.text('Sync now'));
      await tester.tap(find.text('Sync now'));
      await flush(tester);

      expect(fake.requestSyncFromDevicesCalls, 1);
      expect(find.text('Sync requested from 2 devices'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Sync now with nobody connected reports no devices',
        (tester) async {
      fake.serverRunning = true;
      fake.hasPairingKeyResult = true;

      await pumpPairing(tester, size: desktopSize);
      await flush(tester);

      await tester.ensureVisible(find.text('Sync now'));
      await tester.tap(find.text('Sync now'));
      await flush(tester);

      expect(fake.requestSyncFromDevicesCalls, 1);
      expect(find.text('No devices connected'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('surfaces a server-start failure', (tester) async {
      fake.startServerThrows = Exception('no available port');
      await pumpPairing(tester, size: desktopSize);
      await flush(tester);

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a server "paired" event advances to the linked state',
        (tester) async {
      await pumpPairing(tester, size: desktopSize);
      await flush(tester); // reaches serverReady (QR)
      expect(find.byType(QrImageView), findsOneWidget);

      fake.emitServer('paired');
      await flush(tester);

      expect(find.byType(QrImageView), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('mobile view', () {
    testWidgets('idle shows the scan-QR call to action', (tester) async {
      await pumpPairing(tester, size: mobileSize);
      await flush(tester);

      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
      // No stored pairing → no sync / wifi-unlock sections yet.
      expect(find.byType(SyncSummaryCard), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with a stored pairing shows the sync + unlock sections',
        (tester) async {
      fake.hasPairingKeyResult = true;
      await pumpPairing(tester, size: mobileSize);
      await flush(tester);

      expect(find.byIcon(Icons.sync_alt_rounded), findsWidgets); // sync section
      expect(find.byIcon(Icons.wifi_rounded), findsOneWidget); // unlock section
      expect(find.byType(SyncSummaryCard), findsOneWidget);
      // auto-resume must NOT fire when there is no resume data.
      expect(fake.resumeCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a client "paired" event advances to the linked state',
        (tester) async {
      await pumpPairing(tester, size: mobileSize);
      await flush(tester);

      fake.emitClient('paired');
      await flush(tester);

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a client "error:" event shows the error state', (tester) async {
      await pumpPairing(tester, size: mobileSize);
      await flush(tester);

      fake.emitClient('error: link dropped');
      await flush(tester);

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a sync-in-progress event renders the syncing indicator',
        (tester) async {
      fake.hasPairingKeyResult = true;
      await pumpPairing(tester, size: mobileSize);
      await flush(tester);

      fake.emitClient('sync_started');
      await flush(tester);

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
