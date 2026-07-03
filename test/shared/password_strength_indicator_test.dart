import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/password_generator/domain/password_generator.dart';
import 'package:password_manager/shared/widgets/password_strength_indicator.dart';

import '../support/widget_harness.dart';

void main() {
  double barValue(WidgetTester tester) =>
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;

  testWidgets('bar fill grows with strength', (tester) async {
    for (final entry in const {
      PasswordStrength.weak: 0.25,
      PasswordStrength.fair: 0.5,
      PasswordStrength.good: 0.75,
      PasswordStrength.strong: 1.0,
    }.entries) {
      await pumpApp(tester,
          scaffolded(PasswordStrengthIndicator(strength: entry.key)));
      expect(barValue(tester), entry.value, reason: '${entry.key}');
    }
  });

  testWidgets('shows the localized label per strength', (tester) async {
    for (final entry in const {
      PasswordStrength.weak: 'Weak',
      PasswordStrength.fair: 'Fair',
      PasswordStrength.good: 'Good',
      PasswordStrength.strong: 'Strong',
    }.entries) {
      await pumpApp(tester,
          scaffolded(PasswordStrengthIndicator(strength: entry.key)));
      expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}');
    }
  });

  testWidgets('none renders no label and an empty bar', (tester) async {
    await pumpApp(tester,
        scaffolded(const PasswordStrengthIndicator(strength: PasswordStrength.none)));
    expect(barValue(tester), 0.0);
    expect(find.text('Weak'), findsNothing);
  });

  testWidgets('showLabel: false hides the label', (tester) async {
    await pumpApp(
      tester,
      scaffolded(const PasswordStrengthIndicator(
          strength: PasswordStrength.strong, showLabel: false)),
    );
    expect(find.text('Strong'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
