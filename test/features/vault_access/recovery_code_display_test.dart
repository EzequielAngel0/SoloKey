import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault_access/presentation/recovery_screen.dart';

import '../../support/widget_harness.dart';

void main() {
  testWidgets('RecoveryCodeDisplay shows the recovery code and actions',
      (tester) async {
    await pumpApp(
      tester,
      const RecoveryCodeDisplay(code: 'ABCD-EFGH-IJKL', targetRoute: '/'),
      surfaceSize: const Size(440, 900),
    );
    await tester.pump();
    expect(find.text('ABCD-EFGH-IJKL'), findsOneWidget);
    // A continue button (ElevatedButton) and a copy action (OutlinedButton).
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
