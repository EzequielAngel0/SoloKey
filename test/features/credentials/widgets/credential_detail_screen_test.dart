import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:password_manager/core/services/biometric_auth_service.dart';
import 'package:password_manager/features/credentials/application/credential_health_provider.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/credential_detail_screen.dart';

import '../../../support/widget_harness.dart';

/// Fake biometric gate: [result] decides success, [calls] records how many
/// times auth was requested. Never touches a native channel. It NEVER receives
/// or logs the secret value — only the reason string.
class _FakeBio extends BiometricAuthService {
  _FakeBio(this.result);
  bool result;
  int calls = 0;

  @override
  Future<bool> isAuthAvailable() async => true;

  @override
  Future<bool> authenticate({required String reason}) async {
    calls++;
    return result;
  }
}

/// Serves a fixed list so `credentialsNotifierProvider` resolves without the
/// real use case / repository chain.
class _FakeCredsNotifier extends CredentialsNotifier {
  _FakeCredsNotifier(this._items);
  final List<Credential> _items;

  @override
  Future<List<Credential>> build() async => _items;
}

Credential _cred({
  String id = 'c1',
  CredentialType type = CredentialType.password,
  String title = 'GitHub',
  String? username = 'octocat',
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

Finder _monoCode() => find.byWidgetPredicate(
    (w) => w is Text && w.data != null && RegExp(r'^\d{3} \d{3}$').hasMatch(w.data!));

/// Pumps the detail screen with the credential served and health empty.
Future<void> pumpDetail(WidgetTester tester, Credential c) async {
  await pumpApp(
    tester,
    CredentialDetailScreen(credentialId: c.id),
    overrides: [
      credentialsNotifierProvider.overrideWith(() => _FakeCredsNotifier([c])),
      credentialHealthProvider.overrideWithValue(const {}),
    ],
    surfaceSize: const Size(420, 900),
  );
  // Resolve the async notifier build (no pumpAndSettle: TOTP/countdown timers).
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  late _FakeBio bio;

  setUp(() {
    bio = _FakeBio(true);
    GetIt.I.registerSingleton<BiometricAuthService>(bio);
  });
  tearDown(() => GetIt.I.reset());

  group('CredentialDetailScreen — render por tipo', () {
    testWidgets('password shows title, username and a masked secret',
        (tester) async {
      await pumpDetail(
        tester,
        _cred(password: 'S3cr3t-Value!', website: 'https://github.com'),
      );
      expect(find.text('GitHub'), findsWidgets); // app bar + header
      expect(find.text('octocat'), findsOneWidget);
      expect(find.text('S3cr3t-Value!'), findsNothing); // hidden by default
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });

    testWidgets('apiKey renders the key field masked', (tester) async {
      await pumpDetail(
        tester,
        _cred(type: CredentialType.apiKey, title: 'Stripe', password: 'sk_live_x'),
      );
      expect(find.text('Stripe'), findsWidgets);
      expect(find.text('sk_live_x'), findsNothing);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });

    testWidgets('secure note renders its notes body', (tester) async {
      await pumpDetail(
        tester,
        _cred(
          type: CredentialType.secureNote,
          title: 'Wifi',
          username: null,
          notes: 'La contrasena del router',
        ),
      );
      expect(find.text('La contrasena del router'), findsOneWidget);
    });

    testWidgets('ssh key renders its key type in the primary group',
        (tester) async {
      await pumpDetail(
        tester,
        _cred(
          type: CredentialType.sshKey,
          title: 'prod-server',
          username: null,
          password: 'ENCRYPTED_PRIV',
          ssh: const SshKeyMetadata(
            privateKey: 'PRIVATE',
            publicKey: 'ssh-ed25519 AAAA...',
            keyType: 'Ed25519',
          ),
        ),
      );
      expect(find.text('prod-server'), findsWidgets);
      expect(find.text('Ed25519'), findsOneWidget);
    });

    testWidgets('passkey renders its metadata but never the raw handle',
        (tester) async {
      await pumpDetail(
        tester,
        _cred(
          type: CredentialType.passkey,
          title: 'GitHub Passkey',
          username: null,
          password: 'ENCRYPTED_HANDLE_BLOB',
          passkey: const PasskeyMetadata(
            rpId: 'github.com',
            rpName: 'GitHub',
            credentialId: 'CRED-ID-123',
          ),
        ),
      );
      expect(find.text('github.com'), findsOneWidget);
      expect(find.text('CRED-ID-123'), findsOneWidget);
      // The encrypted private-key handle must never be shown, even masked.
      expect(find.text('ENCRYPTED_HANDLE_BLOB'), findsNothing);
      expect(find.byIcon(Icons.visibility_rounded), findsNothing);
    });
  });

  group('CredentialDetailScreen — open site', () {
    testWidgets('login with a website shows the open-site action',
        (tester) async {
      await pumpDetail(
        tester,
        _cred(password: 'x', website: 'https://github.com'),
      );
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
    });

    testWidgets('no website means no open-site action', (tester) async {
      await pumpDetail(tester, _cred(password: 'x'));
      expect(find.byIcon(Icons.open_in_new_rounded), findsNothing);
    });
  });

  group('CredentialDetailScreen — TOTP hero', () {
    testWidgets('valid base32 seed renders a live 6-digit code', (tester) async {
      await pumpDetail(
        tester,
        _cred(
          type: CredentialType.totp,
          title: 'Google',
          password: 'JBSWY3DPEHPK3PXP',
        ),
      );
      expect(_monoCode(), findsOneWidget);
    });

    testWidgets('invalid seed shows the "Invalid" label, not a code',
        (tester) async {
      await pumpDetail(
        tester,
        _cred(
          type: CredentialType.totp,
          title: 'Broken',
          password: 'not-valid-base32!!!',
        ),
      );
      expect(_monoCode(), findsNothing);
      expect(find.text('Invalid'), findsOneWidget);
    });
  });

  group('CredentialDetailScreen — TOTP QR export', () {
    testWidgets('granted auth renders the QR', (tester) async {
      bio.result = true;
      await pumpDetail(
        tester,
        _cred(
          type: CredentialType.totp,
          title: 'Google',
          password: 'JBSWY3DPEHPK3PXP',
        ),
      );
      await tester.tap(find.byIcon(Icons.qr_code_2_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // sheet animates in

      expect(bio.calls, greaterThan(0));
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('denied auth does not render the QR', (tester) async {
      bio.result = false;
      await pumpDetail(
        tester,
        _cred(
          type: CredentialType.totp,
          title: 'Google',
          password: 'JBSWY3DPEHPK3PXP',
        ),
      );
      await tester.tap(find.byIcon(Icons.qr_code_2_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(bio.calls, greaterThan(0));
      expect(find.byType(QrImageView), findsNothing);
    });
  });

  group('CredentialDetailScreen — reveal requires auth', () {
    testWidgets('denied auth keeps the secret masked', (tester) async {
      bio.result = false;
      await pumpDetail(tester, _cred(password: 'S3cr3t-Value!'));

      await tester.tap(find.byIcon(Icons.visibility_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(bio.calls, greaterThan(0)); // auth was requested
      expect(find.text('S3cr3t-Value!'), findsNothing); // still hidden
    });

    testWidgets('granted auth reveals the value and starts the countdown',
        (tester) async {
      bio.result = true;
      await pumpDetail(tester, _cred(password: 'S3cr3t-Value!'));

      await tester.tap(find.byIcon(Icons.visibility_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(bio.calls, greaterThan(0));
      expect(find.text('S3cr3t-Value!'), findsOneWidget); // revealed
      expect(find.text('30s'), findsOneWidget); // auto-hide countdown pill
    });
  });
}
