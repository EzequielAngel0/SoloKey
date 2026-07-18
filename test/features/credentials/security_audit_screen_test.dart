import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:password_manager/core/services/security_audit_service.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/security_audit_screen.dart';
import 'package:password_manager/features/settings/domain/entities/app_security_settings.dart';
import 'package:password_manager/features/settings/presentation/settings_screen.dart';
import 'package:password_manager/l10n/app_localizations.dart';
import 'package:password_manager/router/app_router.dart';
import 'package:password_manager/theme/app_theme.dart';

import '../../support/fake_settings_repository.dart';
import '../../support/widget_harness.dart';

Credential _c(String id) => Credential(
      id: id,
      type: CredentialType.password,
      title: 'cred-$id',
      password: 'abc',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

AuditIssue _issue(
  String id,
  AuditSeverity severity,
  AuditIssueType type, {
  int breachCount = 0,
}) =>
    AuditIssue(
      credential: _c(id),
      severity: severity,
      type: type,
      breachCount: breachCount,
    );

Future<FakeSettingsRepository> pumpAudit(
  WidgetTester tester, {
  required List<AuditIssue> offline,
  List<AuditIssue>? online,
  FakeSettingsRepository? settingsRepo,
}) async {
  tolerateInkHiddenPaintWarnings();
  final repo = settingsRepo ?? FakeSettingsRepository();
  await pumpApp(
    tester,
    const SecurityAuditScreen(),
    overrides: [
      // Override the results provider family directly → no get_it, no crypto.
      auditResultsProvider(false).overrideWith((ref) async => offline),
      if (online != null)
        auditResultsProvider(true).overrideWith((ref) async => online),
      // The HIBP switch reads/persists through AppSecuritySettings.
      settingsRepositoryProvider.overrideWithValue(repo),
    ],
    surfaceSize: const Size(820, 1400),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return repo;
}

void main() {
  testWidgets('clean vault shows the all-good state, no issue cards',
      (tester) async {
    await pumpAudit(tester, offline: const []);

    expect(find.byType(Switch), findsOneWidget); // the breach-check toggle
    expect(find.byType(InkWell), findsNothing); // no tappable issue cards
  });

  testWidgets('findings render one card per issue with its credential title',
      (tester) async {
    await pumpAudit(tester, offline: [
      _issue('1', AuditSeverity.warning, AuditIssueType.tooShort),
      _issue('2', AuditSeverity.critical, AuditIssueType.weakLettersOnly),
    ]);

    expect(find.text('cred-1'), findsOneWidget);
    expect(find.text('cred-2'), findsOneWidget);
    // Severity labels from the score card + per-card badges.
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Warning'), findsWidgets);
  });

  testWidgets(
      'toggling HIBP switches to the breach-aware result set and persists',
      (tester) async {
    final repo = await pumpAudit(
      tester,
      offline: [_issue('1', AuditSeverity.warning, AuditIssueType.tooShort)],
      online: [
        _issue('1', AuditSeverity.warning, AuditIssueType.tooShort),
        _issue('2', AuditSeverity.critical, AuditIssueType.breached,
            breachCount: 3),
      ],
    );

    // Offline pass: only the local finding is visible.
    expect(find.text('cred-1'), findsOneWidget);
    expect(find.text('cred-2'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Online pass (checkBreaches == true) surfaces the breached credential.
    expect(find.text('cred-2'), findsOneWidget);
    // The toggle is written through to settings, not kept as widget state.
    expect(repo.settings.hibpCheckEnabled, isTrue);
  });

  testWidgets('HIBP switch starts ON when settings already persist it',
      (tester) async {
    await pumpAudit(
      tester,
      offline: [_issue('1', AuditSeverity.warning, AuditIssueType.tooShort)],
      online: [
        _issue('2', AuditSeverity.critical, AuditIssueType.breached,
            breachCount: 3),
      ],
      settingsRepo: FakeSettingsRepository(
        AppSecuritySettings.defaults().copyWith(hibpCheckEnabled: true),
      ),
    );

    // The persisted value drives the switch and the breach-aware audit run.
    final switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.value, isTrue);
    expect(find.text('cred-2'), findsOneWidget);
  });

  testWidgets('tapping an issue navigates to the credential editor',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    final router = GoRouter(
      initialLocation: '/audit',
      routes: [
        GoRoute(
          path: '/audit',
          builder: (_, _) => const SecurityAuditScreen(),
        ),
        GoRoute(
          path: AppRoutes.credentialEdit,
          builder: (_, state) => Scaffold(
            body: Text('EDIT ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    await tester.binding.setSurfaceSize(const Size(820, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          auditResultsProvider(false).overrideWith(
            (ref) async =>
                [_issue('42', AuditSeverity.warning, AuditIssueType.tooShort)],
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('cred-42'));
    await tester.pumpAndSettle();

    expect(find.text('EDIT 42'), findsOneWidget);
  });
}
