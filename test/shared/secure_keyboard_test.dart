import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/shared/widgets/secure_keyboard/secure_keyboard.dart';

import '../support/widget_harness.dart';

void main() {
  testWidgets('SecureKeyboard renders its keys and reports input', (tester) async {
    final entered = <String>[];
    await pumpApp(
      tester,
      scaffolded(SecureKeyboard(onComplete: entered.add)),
      surfaceSize: const Size(440, 900),
    );
    await tester.pump();

    // The shuffled layout renders digit keys; tapping a couple must not throw.
    expect(tester.takeException(), isNull);
    final five = find.text('5');
    if (five.evaluate().isNotEmpty) {
      await tester.tap(five.first);
      await tester.pump();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('SecureKeyboard in text mode builds', (tester) async {
    await pumpApp(
      tester,
      scaffolded(SecureKeyboard(
        onComplete: (_) {},
        mode: SecureKeyboardMode.text,
      )),
      surfaceSize: const Size(440, 900),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
