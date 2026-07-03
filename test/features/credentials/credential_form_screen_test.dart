import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/presentation/credential_form_screen.dart';
import 'package:password_manager/features/credentials/presentation/widgets/password_generator_widget.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';

import '../../support/widget_harness.dart';

/// Folders resolve to an empty list so the "Organization" picker builds without
/// the real get_it repository (its provider throws by design).
class _EmptyFoldersNotifier extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

Future<void> pumpForm(WidgetTester tester) async {
  // FormSection is an opaque container; its SwitchListTile children trip
  // Flutter's benign "ink hidden" debug paint check. Ignore just that.
  tolerateInkHiddenPaintWarnings();
  await pumpApp(
    tester,
    const CredentialFormScreen(), // create mode (existingId == null)
    overrides: [
      foldersNotifierProvider.overrideWith(_EmptyFoldersNotifier.new),
    ],
    surfaceSize: const Size(440, 1600),
  );
}

void main() {
  testWidgets('empty title fails validation with a "Required field" error',
      (tester) async {
    await pumpForm(tester);
    await tester.pump();

    // Tap the app-bar confirm (check) action → runs the form validator.
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pump();

    expect(find.text('Required field'), findsWidgets);
  });

  testWidgets('changing the type swaps the visible fields', (tester) async {
    await pumpForm(tester);
    await tester.pump();

    // Password type shows the Login section (FormSection upper-cases titles)...
    expect(find.text('LOGIN CREDENTIALS'), findsOneWidget);
    expect(find.text('2FA SETUP'), findsNothing);

    // Switch to TOTP via the type selector, then let the AnimatedSwitcher fully
    // finish so the outgoing (login) child is removed, not just faded.
    await tester.tap(find.text('TOTP'));
    await tester.pump(); // kick off the transition
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('2FA SETUP'), findsOneWidget);
    expect(find.text('LOGIN CREDENTIALS'), findsNothing);
    expect(find.text('TOTP secret key (Base32)'), findsOneWidget);
  });

  testWidgets('the generator toggle reveals the password generator',
      (tester) async {
    await pumpForm(tester);
    await tester.pump();

    final toggle = find.byIcon(Icons.auto_fix_high_rounded);
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump(const Duration(milliseconds: 400)); // AnimatedSize

    expect(find.byType(PasswordGeneratorWidget), findsOneWidget);
    // The generator surfaces its "Use & copy" action and a length slider.
    expect(find.text('Use & copy'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
