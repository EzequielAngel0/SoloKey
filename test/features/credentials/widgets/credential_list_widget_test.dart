import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_health_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/widgets/credential_card.dart';
import 'package:password_manager/features/credentials/presentation/widgets/credential_list_widget.dart';

import '../../../support/widget_harness.dart';

Credential _c(String id, String title) => Credential(
      id: id,
      type: CredentialType.password,
      title: title,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  final creds = [_c('1', 'GitHub'), _c('2', 'GitLab'), _c('3', 'Bitbucket')];

  Future<void> pumpList(WidgetTester tester,
      {bool reorderMode = false, void Function(int, int)? onReorder}) {
    return pumpApp(
      tester,
      scaffolded(CredentialListWidget(
        credentials: creds,
        reorderMode: reorderMode,
        onReorder: onReorder,
      )),
      overrides: [credentialHealthProvider.overrideWithValue(const {})],
    );
  }

  testWidgets('renders one dense card per credential', (tester) async {
    await pumpList(tester);
    expect(find.byType(CredentialCard), findsNWidgets(3));
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Bitbucket'), findsOneWidget);
  });

  testWidgets('no drag handles outside reorder mode', (tester) async {
    await pumpList(tester);
    expect(find.byIcon(Icons.drag_indicator_rounded), findsNothing);
  });

  testWidgets('shows a drag handle per row in reorder mode', (tester) async {
    await pumpList(tester, reorderMode: true, onReorder: (_, _) {});
    expect(find.byIcon(Icons.drag_indicator_rounded), findsNWidgets(3));
  });

  testWidgets('reorder mode requires an onReorder callback', (tester) async {
    // reorderMode true but no callback → stays in the normal dense list.
    await pumpList(tester, reorderMode: true);
    expect(find.byIcon(Icons.drag_indicator_rounded), findsNothing);
  });
}
