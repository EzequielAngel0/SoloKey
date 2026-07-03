import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/infrastructure/database/app_database.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/infrastructure/credential_dto.dart';

/// Round-trips a credential through the DTO + real Drift row so we prove the
/// sensitive payload survives the JSON<->bytes hop and the plain columns map
/// back correctly. The "encrypted payload" here is the plain JSON bytes
/// (identity crypto) — the AES pipeline is covered by security_service_test.
/// Zero-Print: never log the decoded payload; assert against known values only.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<Credential> roundTrip(Credential c) async {
    final payload = CredentialDto.toPayload(c);
    await db.credentialDao.upsert(
      CredentialDto.toCompanion(credential: c, encryptedPayload: payload.toBytes()),
    );
    final entry = (await db.credentialDao.getById(c.id))!;
    final decoded = CredentialSensitivePayload.fromBytes(entry.encryptedPayload);
    return CredentialDto.fromEntry(entry: entry, payload: decoded);
  }

  test('payload bytes round-trip preserves every sensitive field', () {
    final payload = CredentialDto.toPayload(Credential(
      id: '1',
      type: CredentialType.password,
      title: 'GitHub',
      username: 'octocat',
      password: 's3cr3t-P@ss',
      website: 'https://github.com',
      notes: 'line1\nline2',
      customFields: const [
        CustomField(label: 'PIN', value: '4242', isSecret: true),
        CustomField(label: 'Plan', value: 'Pro'),
      ],
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    ));
    final back = CredentialSensitivePayload.fromBytes(payload.toBytes());
    expect(back.username, 'octocat');
    expect(back.password, 's3cr3t-P@ss');
    expect(back.website, 'https://github.com');
    expect(back.notes, 'line1\nline2');
    expect(back.customFields.length, 2);
    expect(back.customFields.first['isSecret'], true);
  });

  test('full DB round-trip preserves a password credential', () async {
    final original = Credential(
      id: 'pw-1',
      type: CredentialType.password,
      title: 'GitHub',
      username: 'octocat',
      password: 's3cr3t-P@ss',
      website: 'https://github.com',
      notes: 'recovery codes',
      customFields: const [CustomField(label: 'PIN', value: '4242', isSecret: true)],
      categoryId: 'folderX',
      isFavorite: true,
      isDoubleEncrypted: true,
      isHidden: true,
      sortOrder: 5,
      createdAt: DateTime(2020, 1, 1),
      updatedAt: DateTime(2020, 6, 1),
      rotationInterval: 'custom',
      customRotationDays: 45,
      lastRotationPromptedAt: DateTime(2021, 5, 5),
    );
    expect(await roundTrip(original), original);
  });

  test('full DB round-trip preserves a passkey credential + metadata', () async {
    final original = Credential(
      id: 'pk-1',
      type: CredentialType.passkey,
      title: 'Example Passkey',
      password: 'encrypted-handle',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
      passkeyMetadata: const PasskeyMetadata(
        rpId: 'example.com',
        rpName: 'Example Inc.',
        credentialId: 'Y3JlZC1pZA',
        aaguid: 'aa-guid',
        userDisplayName: 'octocat',
      ),
    );
    expect(await roundTrip(original), original);
  });

  test('full DB round-trip preserves an SSH key credential + metadata', () async {
    final original = Credential(
      id: 'ssh-1',
      type: CredentialType.sshKey,
      title: 'Prod server',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
      sshKeyMetadata: const SshKeyMetadata(
        privateKey: 'PRIVATE',
        publicKey: 'ssh-ed25519 AAAA...',
        passphrase: 'phrase',
        keyType: 'Ed25519',
      ),
    );
    expect(await roundTrip(original), original);
  });

  test('toCompanion maps the plain (non-encrypted) columns', () {
    final c = Credential(
      id: 'x',
      type: CredentialType.apiKey,
      title: 'Key',
      isFavorite: true,
      sortOrder: 9,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );
    final companion =
        CredentialDto.toCompanion(credential: c, encryptedPayload: CredentialDto.toPayload(c).toBytes());
    expect(companion.title.value, 'Key');
    expect(companion.type.value, 'apiKey');
    expect(companion.isFavorite.value, true);
    expect(companion.sortOrder.value, 9);
  });
}
