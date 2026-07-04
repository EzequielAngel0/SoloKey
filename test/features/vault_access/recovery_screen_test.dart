import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault_access/presentation/recovery_screen.dart';
import 'package:password_manager/shared/widgets/step_indicator.dart';

import '../../support/widget_harness.dart';

void main() {
  testWidgets('RecoveryScreen step 1 shows the 2-step indicator and code input',
      (tester) async {
    // Step 1 (enter code) reads no providers/get_it on build, so no overrides.
    await pumpApp(
      tester,
      const RecoveryScreen(),
      surfaceSize: const Size(440, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    // Two-step progress indicator is present.
    expect(find.byType(StepIndicator), findsOneWidget);
    expect(find.text('Step 1 of 2 · Enter your recovery code'), findsOneWidget);
    // The code field and the verify action.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
