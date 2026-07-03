import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/credential_form_screen.dart';
import 'package:password_manager/features/credentials/presentation/widgets/password_generator_widget.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/l10n/app_localizations.dart';
import 'package:password_manager/shared/widgets/password_strength_indicator.dart';
import 'package:password_manager/shared/widgets/secure_text_field.dart';
import 'package:password_manager/theme/app_theme.dart';

import '../../support/widget_harness.dart';

/// Folders resolve to an empty list so the "Organization" picker builds without
/// the real get_it repository (its provider throws by design).
class _EmptyFoldersNotifier extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

/// Serves a single credential synchronously so `_loadExisting` (which runs in
/// `initState`, before any async build resolves) can read it via `valueOrNull`.
class _OneCredentialNotifier extends CredentialsNotifier {
  _OneCredentialNotifier(this.credential);
  final Credential credential;
  @override
  Future<List<Credential>> build() => SynchronousFuture([credential]);
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

/// Pumps the form pushed onto a launcher route, so it has a real back button and
/// a route to pop back to (needed to exercise the unsaved-changes guard).
Future<void> pumpFormPushed(
  WidgetTester tester, {
  Widget form = const CredentialFormScreen(),
  List<Override> overrides = const [],
}) async {
  tolerateInkHiddenPaintWarnings();
  await tester.binding.setSurfaceSize(const Size(440, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        foldersNotifierProvider.overrideWith(_EmptyFoldersNotifier.new),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => form),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
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

  testWidgets('edit mode preloads the existing credential fields',
      (tester) async {
    final cred = Credential(
      id: 'c-1',
      type: CredentialType.password,
      title: 'GitHub',
      username: 'octocat',
      password: 's3cr3t',
      website: 'https://github.com',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );
    await pumpFormPushed(
      tester,
      form: const CredentialFormScreen(existingId: 'c-1'),
      overrides: [
        credentialsNotifierProvider.overrideWith(
          () => _OneCredentialNotifier(cred),
        ),
      ],
    );

    // Header reflects edit mode, and the top fields show the preloaded values.
    // (The bottom "Save changes" CTA lives past the lazy ListView viewport.)
    expect(find.text('Edit credential'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'GitHub'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'octocat'), findsOneWidget);
  });

  testWidgets('editing a field then pressing back prompts to discard',
      (tester) async {
    await pumpFormPushed(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Draft entry');
    await tester.pump();

    // Simulate the system/app-bar back (routed through the form's PopScope).
    await tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
    await tester.pumpAndSettle();

    // Guard dialog appears; "Keep editing" stays on the form.
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Draft entry'), findsOneWidget);
  });

  testWidgets('an untouched form pops back without the discard prompt',
      (tester) async {
    await pumpFormPushed(tester);

    await tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('open'), findsOneWidget); // back on the launcher route
  });

  testWidgets('typing a password reveals the live strength meter',
      (tester) async {
    await pumpForm(tester);
    await tester.pump();

    // No indicator while the password field is empty.
    expect(find.byType(PasswordStrengthIndicator), findsNothing);

    await tester.enterText(find.byType(SecureTextField), 'Xy9#kLmn2Pqr');
    await tester.pump();

    expect(find.byType(PasswordStrengthIndicator), findsOneWidget);
    expect(find.text('Strong'), findsOneWidget);
  });

  testWidgets('an invalid website URL fails inline validation',
      (tester) async {
    await pumpForm(tester);
    await tester.pump();

    final website = find.ancestor(
      of: find.text('Website / URL'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(website, 'not a valid url');
    await tester.pump();

    expect(find.text('Enter a valid URL'), findsOneWidget);
  });

  testWidgets('an invalid Base32 TOTP secret fails inline validation',
      (tester) async {
    await pumpForm(tester);
    await tester.pump();

    // Switch to TOTP and let the AnimatedSwitcher settle.
    await tester.tap(find.text('TOTP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    // '1' and '8' are not part of the Base32 alphabet (A–Z, 2–7).
    await tester.enterText(find.byType(SecureTextField), '11111111');
    await tester.pump();

    expect(find.text('Invalid Base32 secret (only A–Z and 2–7)'),
        findsOneWidget);
  });
}
