import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/shared/widgets/secure_text_field.dart';

import '../support/widget_harness.dart';

void main() {
  bool isObscured(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).obscureText;

  testWidgets('starts obscured with the reveal (eye-off) icon', (tester) async {
    await pumpApp(
      tester,
      scaffolded(SecureTextField(
        controller: TextEditingController(),
        label: 'Master password',
      )),
    );
    expect(isObscured(tester), isTrue);
    expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
    expect(find.text('Master password'), findsOneWidget);
  });

  testWidgets('toggling the icon reveals and re-hides the text', (tester) async {
    await pumpApp(
      tester,
      scaffolded(SecureTextField(
        controller: TextEditingController(text: 'hunter2'),
        label: 'Password',
      )),
    );

    await tester.tap(find.byIcon(Icons.visibility_off_rounded));
    await tester.pump();
    expect(isObscured(tester), isFalse);
    expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_rounded));
    await tester.pump();
    expect(isObscured(tester), isTrue);
  });

  testWidgets('runs the validator inside a Form', (tester) async {
    final formKey = GlobalKey<FormState>();
    await pumpApp(
      tester,
      scaffolded(Form(
        key: formKey,
        child: SecureTextField(
          controller: TextEditingController(),
          label: 'Password',
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
      )),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });
}
