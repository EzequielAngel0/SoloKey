import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/sync/application/sync_status_provider.dart';
import 'package:password_manager/features/sync/domain/sync_summary.dart';
import 'package:password_manager/features/sync/presentation/widgets/sync_summary_card.dart';
import 'package:password_manager/l10n/app_localizations.dart';
import 'package:password_manager/theme/app_theme.dart';

/// Overrides [SyncStatus] with a fixed state so the card can be rendered without
/// the sync engine / DI.
class _FakeSyncStatus extends SyncStatus {
  _FakeSyncStatus(this._state);
  final SyncStatusState _state;
  @override
  SyncStatusState build() => _state;
}

Future<void> _pump(WidgetTester tester, SyncStatusState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncStatusProvider.overrideWith(() => _FakeSyncStatus(state)),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(child: SyncSummaryCard()),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  testWidgets('renders nothing before any sync', (tester) async {
    await _pump(tester, const SyncStatusState(phase: SyncPhase.idle));
    expect(find.byType(SyncSummaryCard), findsOneWidget);
    expect(find.text(l10n.syncSummaryTitle.toUpperCase()), findsNothing);
  });

  testWidgets('shows counts and reveals item names on toggle', (tester) async {
    final summary = SyncSummary(
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      deviceName: 'PC',
      changes: const [
        SyncItemChange(
            id: '1',
            name: 'GitHub',
            kind: SyncEntityKind.credential,
            action: SyncChangeAction.added),
        SyncItemChange(
            id: '2',
            name: 'Gmail',
            kind: SyncEntityKind.credential,
            action: SyncChangeAction.added),
        SyncItemChange(
            id: '3',
            name: 'Work',
            kind: SyncEntityKind.folder,
            action: SyncChangeAction.updated),
      ],
    );
    await _pump(
      tester,
      SyncStatusState(
          phase: SyncPhase.success,
          lastSummary: summary,
          history: [summary]),
    );

    // Header + counts render.
    expect(find.text(l10n.syncSummaryTitle.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.syncCountAdded(2)), findsOneWidget); // 2 credentials
    expect(find.text(l10n.syncCountUpdated(1)), findsOneWidget); // 1 folder

    // Item names hidden until the toggle is tapped.
    expect(find.text('GitHub'), findsNothing);
    await tester.tap(find.text(l10n.syncItemsShow));
    await tester.pump();
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Gmail'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('empty round shows the no-changes message', (tester) async {
    final empty = SyncSummary.empty();
    await _pump(
      tester,
      SyncStatusState(phase: SyncPhase.success, lastSummary: empty),
    );
    expect(find.text(l10n.syncSummaryNoChanges), findsOneWidget);
  });
}
