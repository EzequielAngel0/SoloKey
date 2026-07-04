import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault_access/presentation/setup_screen.dart';
import 'package:password_manager/shared/widgets/password_requirements_checklist.dart';
import 'package:password_manager/shared/widgets/step_indicator.dart';

import '../../support/widget_harness.dart';

void main() {
  testWidgets('SetupScreen shows the stepper, both fields and the checklist',
      (tester) async {
    // VaultNotifier.build() is initial() and SetupScreen reads no get_it on
    // build, so no overrides are needed.
    await pumpApp(
      tester,
      const SetupScreen(),
      surfaceSize: const Size(440, 1100),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(StepIndicator), findsOneWidget);
    expect(find.text('Step 1 of 2 · Create your master password'),
        findsOneWidget);
    // Master + confirm fields.
    expect(find.byType(TextField), findsNWidgets(2));
    // The shared requirements checklist and the single create button.
    expect(find.byType(PasswordRequirementsChecklist), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('a password below the policy is rejected on submit',
      (tester) async {
    await pumpApp(
      tester,
      const SetupScreen(),
      surfaceSize: const Size(440, 1100),
    );
    await tester.pump();

    // Same weak value in both fields → the confirm matches, so only the master
    // policy validator fires (min length), never reaching the use case.
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'short');
    await tester.enterText(fields.at(1), 'short');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('At least 12 characters'), findsWidgets);
  });
}
