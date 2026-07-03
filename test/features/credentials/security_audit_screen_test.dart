import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/services/security_audit_service.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/security_audit_screen.dart';

import '../../support/widget_harness.dart';

Credential _c(String id) => Credential(
      id: id,
      type: CredentialType.password,
      title: 'cred-$id',
      password: 'abc',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

Future<void> pumpAudit(WidgetTester tester, List<AuditIssue> issues) async {
  tolerateInkHiddenPaintWarnings();
  await pumpApp(
    tester,
    const SecurityAuditScreen(),
    overrides: [
      // Override the results provider directly → no get_it / no real crypto.
      auditResultsProvider(false).overrideWith((ref) async => issues),
    ],
    surfaceSize: const Size(820, 1400),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('renders the clean state when there are no issues',
      (tester) async {
    await pumpAudit(tester, const []);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the issues list when the vault has findings',
      (tester) async {
    await pumpAudit(tester, [
      AuditIssue(
        credential: _c('1'),
        severity: AuditSeverity.warning,
        type: AuditIssueType.tooShort,
      ),
      AuditIssue(
        credential: _c('2'),
        severity: AuditSeverity.critical,
        type: AuditIssueType.weakLettersOnly,
      ),
    ]);
    expect(find.text('cred-1'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
