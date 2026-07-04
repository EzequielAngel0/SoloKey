import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:password_manager/core/infrastructure/security/double_envelope_service.dart';
import 'package:password_manager/core/infrastructure/security/i_security_service.dart';
import 'package:password_manager/core/services/ssh_key_generator_service.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/domain/entities/password_history.dart';
import 'package:password_manager/features/credentials/domain/repositories/i_credential_repository.dart';
import 'package:password_manager/features/credentials/presentation/credential_form_screen.dart';
import 'package:password_manager/features/credentials/presentation/widgets/favorite_toggle.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/l10n/app_localizations.dart';
import 'package:password_manager/shared/widgets/secure_text_field.dart';
import 'package:password_manager/theme/app_theme.dart';

import '../../support/widget_harness.dart';

/// Batch 1 (prompt 97): drives the credential form's *save* flow end to end and
/// captures the [Credential] the form actually builds, so we can assert it is
/// assembled correctly **per type**, with double-envelope, favorite and rotation
/// wired right. These are behavioral: they fail if `_buildCredential` regresses,
/// not merely if the screen renders.
///
/// All tests pump at desktop width (>720) so a successful save takes the desktop
/// branch (updates the right-pane providers) instead of `context.pop()`, which
/// would need a GoRouter the widget harness doesn't provide. The save logic under
/// test (`_buildCredential` + the double-envelope pipeline) is identical either
/// way. Zero-Print: the fake records plaintext args in memory for assertions and
/// never prints them.

/// Repository spy: records what the save/update use case forwards, and keeps an
/// in-memory list so a post-save `refresh()` resolves.
class SaveSpyRepo implements ICredentialRepository {
  SaveSpyRepo([List<Credential>? initial]) : _items = [...?initial];
  final List<Credential> _items;
  final List<Credential> saved = [];
  final List<Credential> updated = [];

  @override
  Future<List<Credential>> getAll() async => List.of(_items);

  @override
  Future<void> save(Credential c) async {
    saved.add(c);
    _items.add(c);
  }

  @override
  Future<void> update(Credential c) async {
    updated.add(c);
    final i = _items.indexWhere((e) => e.id == c.id);
    if (i != -1) _items[i] = c;
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((c) => c.id == id);

  @override
  Future<Credential?> getById(String id) async =>
      _items.where((c) => c.id == id).firstOrNull;

  @override
  Future<List<Credential>> getByCategory(String id) async =>
      _items.where((c) => c.categoryId == id).toList();

  @override
  Future<List<Credential>> getFavorites() async =>
      _items.where((c) => c.isFavorite).toList();

  @override
  Future<List<Credential>> search(String q) async => List.of(_items);

  @override
  Future<List<PasswordHistory>> getPasswordHistory(String id) async => const [];

  @override
  Future<void> setHidden(String id, bool hidden) async {}

  @override
  Future<void> reorder(List<String> ids) async {}

  @override
  Future<void> moveToFolder(String id, String? folderId) async {}

  @override
  Future<void> reassignFolder(String from, String? to) async {}
}

/// Never exercised: the fake double-envelope overrides every method that would
/// touch the real security service, so its members throw if reached.
class _UnusedSecurity implements ISecurityService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('security service is not used in form-save tests');
}

/// Stand-in [DoubleEnvelopeService]: marks ciphertext with the real prefix so the
/// captured credential looks encrypted, and records which credentials had their
/// PIN saved/deleted — all without real crypto or a Keystore.
class _FakeDoubleEnvelope extends DoubleEnvelopeService {
  _FakeDoubleEnvelope()
      : super(_UnusedSecurity(), const FlutterSecureStorage());

  final List<String> encryptedPlaintexts = [];
  final List<String> savedPinFor = [];
  final List<String> deletedPinFor = [];
  String? storedPin;

  @override
  Future<String> encryptField({
    required String plaintext,
    required String pin,
  }) async {
    encryptedPlaintexts.add(plaintext);
    return 'double_enc_v1:salt:cipher';
  }

  @override
  Future<String> decryptField({
    required String encryptedValue,
    required String pin,
  }) async =>
      'plaintext';

  @override
  Future<void> savePinToSecureStorage({
    required String credentialId,
    required String pin,
  }) async =>
      savedPinFor.add(credentialId);

  @override
  Future<void> deletePinFromSecureStorage(String credentialId) async =>
      deletedPinFor.add(credentialId);

  @override
  Future<String?> getPinFromSecureStorage(String credentialId) async =>
      storedPin;
}

/// Returns fixed keys so the SSH-generate path is deterministic and crypto-free.
class _FakeSshGenerator extends SshKeyGeneratorService {
  @override
  Future<SshKeyPairResult> generateEd25519KeyPair({
    String comment = 'solokey-key',
  }) async =>
      SshKeyPairResult(privateKey: 'FAKE_PRIV', publicKey: 'FAKE_PUB');
}

class _EmptyFolders extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

/// Serves the given credentials synchronously so `_loadExisting` (runs in
/// `initState`) sees them without waiting for an async build.
class _SyncCreds extends CredentialsNotifier {
  _SyncCreds(this.items);
  final List<Credential> items;
  @override
  Future<List<Credential>> build() => SynchronousFuture(items);
}

const _desktopSurface = Size(900, 3200);

Future<SaveSpyRepo> pumpCreateForm(
  WidgetTester tester, {
  List<Credential> initial = const [],
}) async {
  tolerateInkHiddenPaintWarnings();
  final repo = SaveSpyRepo(initial);
  await pumpApp(
    tester,
    const CredentialFormScreen(),
    overrides: [
      foldersNotifierProvider.overrideWith(_EmptyFolders.new),
      getCredentialsUseCaseProvider
          .overrideWithValue(GetCredentialsUseCase(repo)),
      saveCredentialUseCaseProvider
          .overrideWithValue(SaveCredentialUseCase(repo)),
    ],
    surfaceSize: _desktopSurface,
  );
  await tester.pump();
  return repo;
}

Future<void> pumpEditForm(
  WidgetTester tester,
  String existingId,
  List<Credential> items,
  SaveSpyRepo repo,
) async {
  tolerateInkHiddenPaintWarnings();
  await pumpApp(
    tester,
    CredentialFormScreen(existingId: existingId),
    overrides: [
      foldersNotifierProvider.overrideWith(_EmptyFolders.new),
      credentialsNotifierProvider.overrideWith(() => _SyncCreds(items)),
      getCredentialsUseCaseProvider
          .overrideWithValue(GetCredentialsUseCase(repo)),
      saveCredentialUseCaseProvider
          .overrideWithValue(SaveCredentialUseCase(repo)),
    ],
    surfaceSize: _desktopSurface,
  );
  await tester.pump();
}

/// Enters [text] into the field whose floating label is [label].
Future<void> _enter(WidgetTester tester, String label, String text) async {
  final field = find
      .ancestor(of: find.text(label), matching: find.byType(TextFormField))
      .first;
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

/// Switches the credential type via the top selector and lets the
/// AnimatedSwitcher fully settle so the outgoing fields are gone.
Future<void> _selectType(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 350));
}

/// Taps the app-bar confirm action and pumps past the save animation + async
/// persistence (no pumpAndSettle: a CircularProgressIndicator spins meanwhile).
Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.check_rounded));
  for (var i = 0; i < 7; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  late _FakeDoubleEnvelope fakeDe;

  setUp(() {
    if (GetIt.I.isRegistered<DoubleEnvelopeService>()) GetIt.I.reset();
    fakeDe = _FakeDoubleEnvelope();
    GetIt.I.registerSingleton<DoubleEnvelopeService>(fakeDe);
  });
  tearDown(() => GetIt.I.reset());

  group('build a credential per type (create mode)', () {
    testWidgets('password: title/username/password/website land on the model',
        (tester) async {
      final repo = await pumpCreateForm(tester);

      await tester.enterText(find.byType(TextFormField).first, 'GitHub');
      await tester.pump();
      await _enter(tester, 'Username / Email', 'octocat');
      await tester.enterText(find.byType(SecureTextField), 'S3cr3t-Value!');
      await tester.pump();
      await _enter(tester, 'Website / URL', 'https://github.com');

      await _tapSave(tester);

      expect(repo.saved, hasLength(1));
      final c = repo.saved.single;
      expect(c.type, CredentialType.password);
      expect(c.title, 'GitHub');
      expect(c.username, 'octocat');
      expect(c.password, 'S3cr3t-Value!');
      expect(c.website, 'https://github.com');
      expect(c.isFavorite, isFalse);
      expect(c.isDoubleEncrypted, isFalse);
    });

    testWidgets('apiKey: service→username, key→password, scopes custom field',
        (tester) async {
      final repo = await pumpCreateForm(tester);
      await _selectType(tester, 'API key');

      await tester.enterText(find.byType(TextFormField).first, 'Stripe');
      await tester.pump();
      await _enter(tester, 'Service name', 'stripe-prod');
      await tester.enterText(find.byType(SecureTextField), 'sk_live_123');
      await tester.pump();
      await _enter(tester, 'Endpoint URL', 'https://api.stripe.com');
      await _enter(tester, 'Permissions / Scopes', 'read,write');

      await _tapSave(tester);

      final c = repo.saved.single;
      expect(c.type, CredentialType.apiKey);
      expect(c.username, 'stripe-prod');
      expect(c.password, 'sk_live_123');
      expect(c.website, 'https://api.stripe.com');
      expect(
        c.customFields.any((f) => f.label == 'scopes' && f.value == 'read,write'),
        isTrue,
      );
    });

    testWidgets('totp: secret→password and issuer becomes a custom field',
        (tester) async {
      final repo = await pumpCreateForm(tester);
      await _selectType(tester, 'TOTP');

      await tester.enterText(find.byType(TextFormField).first, 'Google');
      await tester.pump();
      await _enter(tester, 'Account / Issuer', 'Google');
      await tester.enterText(find.byType(SecureTextField), 'JBSWY3DPEHPK3PXP');
      await tester.pump();

      await _tapSave(tester);

      final c = repo.saved.single;
      expect(c.type, CredentialType.totp);
      expect(c.password, 'JBSWY3DPEHPK3PXP');
      expect(
        c.customFields.any((f) => f.label == 'issuer' && f.value == 'Google'),
        isTrue,
      );
    });

    testWidgets('secure note: content lands in notes', (tester) async {
      final repo = await pumpCreateForm(tester);
      await _selectType(tester, 'Note');

      await tester.enterText(find.byType(TextFormField).first, 'Router');
      await tester.pump();
      await _enter(tester, 'Secure content', 'router-admin-pass');

      await _tapSave(tester);

      final c = repo.saved.single;
      expect(c.type, CredentialType.secureNote);
      expect(c.notes, 'router-admin-pass');
      expect(c.password, isNull);
    });

    testWidgets('ssh key: manual keys build the SshKeyMetadata + password',
        (tester) async {
      final repo = await pumpCreateForm(tester);
      await _selectType(tester, 'SSH key');

      await tester.enterText(find.byType(TextFormField).first, 'prod-server');
      await tester.pump();
      await _enter(
        tester,
        'Private key',
        '-----BEGIN OPENSSH PRIVATE KEY-----\nABC\n-----END OPENSSH PRIVATE KEY-----',
      );
      await _enter(tester, 'Public key (Optional)', 'ssh-ed25519 AAAA');

      await _tapSave(tester);

      final c = repo.saved.single;
      expect(c.type, CredentialType.sshKey);
      expect(c.sshKeyMetadata, isNotNull);
      expect(c.sshKeyMetadata!.privateKey, contains('BEGIN OPENSSH'));
      expect(c.sshKeyMetadata!.publicKey, 'ssh-ed25519 AAAA');
      expect(c.password, contains('BEGIN OPENSSH'));
    });
  });

  group('favorite + rotation', () {
    testWidgets('toggling favorite sets isFavorite on the saved model',
        (tester) async {
      final repo = await pumpCreateForm(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Fav Entry');
      await tester.pump();

      await tester.tap(find.byType(FavoriteToggle));
      await tester.pump(const Duration(milliseconds: 250));

      await _tapSave(tester);

      expect(repo.saved.single.isFavorite, isTrue);
    });

    testWidgets('choosing a monthly reminder sets rotationInterval',
        (tester) async {
      final repo = await pumpCreateForm(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Rotating');
      await tester.pump();

      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every month').last);
      await tester.pumpAndSettle();

      await _tapSave(tester);

      expect(repo.saved.single.rotationInterval, 'monthly');
    });

    testWidgets('custom rotation captures the day count', (tester) async {
      final repo = await pumpCreateForm(tester);
      await tester.enterText(find.byType(TextFormField).first, 'CustomRot');
      await tester.pump();

      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom (days)').last);
      await tester.pumpAndSettle();

      await _enter(tester, 'Days to remind', '45');
      await _tapSave(tester);

      final c = repo.saved.single;
      expect(c.rotationInterval, 'custom');
      expect(c.customRotationDays, 45);
    });
  });

  group('double-envelope encryption', () {
    testWidgets('enabling it (with PIN + biometric) encrypts and stores the PIN',
        (tester) async {
      final repo = await pumpCreateForm(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Secret Vault');
      await tester.pump();
      await tester.enterText(find.byType(SecureTextField), 'topSecret9');
      await tester.pump();

      final deSwitch = find.ancestor(
        of: find.text('Enable double encryption'),
        matching: find.byType(SwitchListTile),
      );
      await tester.ensureVisible(deSwitch);
      await tester.tap(deSwitch);
      await tester.pump();

      await _enter(tester, 'Secondary PIN', '1234');

      final bioSwitch = find.ancestor(
        of: find.text('Biometric unlock'),
        matching: find.byType(SwitchListTile),
      );
      await tester.ensureVisible(bioSwitch);
      await tester.tap(bioSwitch);
      await tester.pump();

      await _tapSave(tester);

      final c = repo.saved.single;
      expect(c.isDoubleEncrypted, isTrue);
      expect(c.password, startsWith('double_enc_v1:'));
      expect(fakeDe.encryptedPlaintexts, contains('topSecret9'));
      expect(fakeDe.savedPinFor, contains(c.id));
    });

    testWidgets('enabling it without a PIN blocks the save via validation',
        (tester) async {
      final repo = await pumpCreateForm(tester);
      await tester.enterText(find.byType(TextFormField).first, 'No Pin Vault');
      await tester.pump();
      await tester.enterText(find.byType(SecureTextField), 'topSecret9');
      await tester.pump();

      final deSwitch = find.ancestor(
        of: find.text('Enable double encryption'),
        matching: find.byType(SwitchListTile),
      );
      await tester.ensureVisible(deSwitch);
      await tester.tap(deSwitch);
      await tester.pump();

      await _tapSave(tester);

      expect(repo.saved, isEmpty);
      expect(find.text('The secondary PIN is required'), findsWidgets);
    });
  });

  group('edit mode (update path)', () {
    Credential existing() => Credential(
          id: 'c1',
          type: CredentialType.password,
          title: 'Old title',
          username: 'user',
          password: 'oldpass',
          website: 'https://old.example.com',
          createdAt: DateTime(2020),
          updatedAt: DateTime(2020),
          rotationInterval: 'monthly',
          lastRotationPromptedAt: DateTime(2021),
        );

    testWidgets('editing forwards to update, keeps id and createdAt',
        (tester) async {
      final e = existing();
      final repo = SaveSpyRepo([e]);
      await pumpEditForm(tester, 'c1', [e], repo);

      await tester.enterText(find.byType(TextFormField).first, 'New title');
      await _tapSave(tester);

      expect(repo.saved, isEmpty);
      expect(repo.updated, hasLength(1));
      final c = repo.updated.single;
      expect(c.id, 'c1');
      expect(c.title, 'New title');
      expect(c.createdAt, DateTime(2020));
    });

    testWidgets('changing the password resets lastRotationPromptedAt',
        (tester) async {
      final e = existing();
      final repo = SaveSpyRepo([e]);
      await pumpEditForm(tester, 'c1', [e], repo);

      await tester.enterText(find.byType(SecureTextField), 'brandNewPass');
      await tester.pump();
      await _tapSave(tester);

      final c = repo.updated.single;
      expect(c.password, 'brandNewPass');
      expect(c.lastRotationPromptedAt, isNull);
    });

    testWidgets('editing another field keeps lastRotationPromptedAt intact',
        (tester) async {
      final e = existing();
      final repo = SaveSpyRepo([e]);
      await pumpEditForm(tester, 'c1', [e], repo);

      await tester.enterText(find.byType(TextFormField).first, 'Renamed only');
      await _tapSave(tester);

      final c = repo.updated.single;
      expect(c.password, 'oldpass');
      expect(c.lastRotationPromptedAt, DateTime(2021));
    });
  });

  group('ssh key generation', () {
    testWidgets('generate button fills the key pair from the service',
        (tester) async {
      GetIt.I.registerSingleton<SshKeyGeneratorService>(_FakeSshGenerator());
      final repo = await pumpCreateForm(tester);
      await _selectType(tester, 'SSH key');

      await tester.enterText(find.byType(TextFormField).first, 'gen-server');
      await tester.pump();

      final genBtn = find.text('Generate Ed25519 key pair');
      await tester.ensureVisible(genBtn);
      await tester.tap(genBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await _tapSave(tester);

      final c = repo.saved.single;
      expect(c.sshKeyMetadata!.privateKey, 'FAKE_PRIV');
      expect(c.sshKeyMetadata!.publicKey, 'FAKE_PUB');
    });
  });

  group('mobile layout (phone width)', () {
    testWidgets('saving at phone width persists then pops to the prior route',
        (tester) async {
      final repo = SaveSpyRepo();
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('HOME'))),
          ),
          GoRoute(
            path: '/new',
            builder: (_, _) => const CredentialFormScreen(),
          ),
        ],
      );
      // Force a real phone viewport (logical 430 wide → isDesktop == false).
      tester.view.physicalSize = const Size(430, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tolerateInkHiddenPaintWarnings();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foldersNotifierProvider.overrideWith(_EmptyFolders.new),
            getCredentialsUseCaseProvider
                .overrideWithValue(GetCredentialsUseCase(repo)),
            saveCredentialUseCaseProvider
                .overrideWithValue(SaveCredentialUseCase(repo)),
          ],
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      router.push('/new');
      await tester.pumpAndSettle();

      // No overflow at ~phone width, and the title field is reachable.
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextFormField).first, 'Mobile Cred');
      await tester.pump();

      await _tapSave(tester);
      await tester.pumpAndSettle();

      // Mobile branch: it saves and pops back to /home (no desktop right pane).
      expect(repo.saved.single.title, 'Mobile Cred');
      expect(find.byType(CredentialFormScreen), findsNothing);
      expect(find.text('HOME'), findsOneWidget);
    });
  });
}
