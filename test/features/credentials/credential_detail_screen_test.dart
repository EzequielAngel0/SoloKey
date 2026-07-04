import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/credential_detail_screen.dart';
import 'package:password_manager/l10n/app_localizations.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/widget_harness.dart';

Credential _c({
  required String id,
  required CredentialType type,
  String title = 'Item',
  String? username,
  String? password,
  String? website,
  String? notes,
  SshKeyMetadata? ssh,
  PasskeyMetadata? passkey,
}) =>
    Credential(
      id: id,
      type: type,
      title: title,
      username: username,
      password: password,
      website: website,
      notes: notes,
      sshKeyMetadata: ssh,
      passkeyMetadata: passkey,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

Future<void> pumpDetail(WidgetTester tester, Credential cred) async {
  tolerateInkHiddenPaintWarnings();
  await pumpApp(
    tester,
    CredentialDetailScreen(credentialId: cred.id),
    overrides: [
      getCredentialsUseCaseProvider
          .overrideWithValue(GetCredentialsUseCase(FakeCredentialRepository([cred]))),
    ],
    surfaceSize: const Size(440, 1400),
  );
  await tester.pump(); // resolve the async vault
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('renders a password credential detail', (tester) async {
    await pumpDetail(
      tester,
      _c(
        id: '1',
        type: CredentialType.password,
        title: 'GitHub',
        username: 'octocat',
        password: 's3cr3t',
        website: 'https://github.com',
        notes: 'note',
      ),
    );
    expect(find.text('GitHub'), findsWidgets);
    // Username shows; the secret stays masked until an authed reveal.
    expect(find.text('octocat'), findsOneWidget);
    expect(find.text('s3cr3t'), findsNothing);
    expect(find.byIcon(Icons.visibility_rounded), findsWidgets);
  });

  testWidgets('renders a TOTP credential detail (timer alive)', (tester) async {
    await pumpDetail(
      tester,
      _c(id: '2', type: CredentialType.totp, title: 'Authy', password: 'JBSWY3DPEHPK3PXP'),
    );
    expect(find.text('Authy'), findsWidgets);
    // TOTP details offer the QR-export action (behind an auth gate on tap).
    expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
  });

  testWidgets('renders an SSH key credential detail', (tester) async {
    await pumpDetail(
      tester,
      _c(
        id: '3',
        type: CredentialType.sshKey,
        title: 'Prod server',
        ssh: const SshKeyMetadata(
          privateKey: 'PRIVATE',
          publicKey: 'ssh-ed25519 AAAA',
          keyType: 'Ed25519',
        ),
      ),
    );
    expect(find.text('Prod server'), findsWidgets);
    expect(find.text('Ed25519'), findsOneWidget);
  });

  testWidgets('passkey detail shows metadata but never the raw handle',
      (tester) async {
    await pumpDetail(
      tester,
      _c(
        id: '4',
        type: CredentialType.passkey,
        title: 'Example Passkey',
        password: 'handle',
        passkey: const PasskeyMetadata(rpId: 'example.com', credentialId: 'abc'),
      ),
    );
    expect(find.text('Example Passkey'), findsWidgets);
    expect(find.text('example.com'), findsWidgets);
    // Zero-Print: the encrypted private-key handle is never rendered.
    expect(find.text('handle'), findsNothing);
  });

  testWidgets('renders a secure note detail with its body', (tester) async {
    await pumpDetail(
      tester,
      _c(id: '5', type: CredentialType.secureNote, title: 'My note', notes: 'secret body'),
    );
    expect(find.text('My note'), findsWidgets);
    expect(find.text('secret body'), findsOneWidget);
  });

  testWidgets('AppBar icon actions expose accessibility tooltips',
      (tester) async {
    await pumpDetail(
      tester,
      _c(
        id: 'a11y',
        type: CredentialType.password,
        title: 'GitHub',
        username: 'octocat',
        password: 's3cr3t',
      ),
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(CredentialDetailScreen)),
    );
    // Icon-only actions must carry a tooltip so screen readers (and desktop
    // hover) can name them.
    expect(find.byTooltip(l10n.commonEdit), findsOneWidget);
    expect(find.byTooltip(l10n.commonDelete), findsOneWidget);
    expect(find.byTooltip(l10n.detailRevealSecret), findsWidgets);
  });

  testWidgets('shows a not-found state for a missing id', (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const CredentialDetailScreen(credentialId: 'ghost'),
      overrides: [
        getCredentialsUseCaseProvider
            .overrideWithValue(GetCredentialsUseCase(FakeCredentialRepository(const []))),
      ],
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Credential not found'), findsOneWidget);
  });
}
