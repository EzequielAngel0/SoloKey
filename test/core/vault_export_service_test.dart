import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/infrastructure/security/i_security_service.dart';
import 'package:password_manager/core/infrastructure/security/security_service_impl.dart';
import 'package:password_manager/core/infrastructure/security/session_manager.dart';
import 'package:password_manager/core/services/vault_export_service.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/domain/entities/password_history.dart';
import 'package:password_manager/features/credentials/domain/repositories/i_credential_repository.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';

import '../support/fake_folder_repository.dart';

/// In-memory credential repo whose save/delete actually persist, so the
/// round-trip import can be asserted (the shared support fake is a no-op).
class _MutableCredRepo implements ICredentialRepository {
  _MutableCredRepo([List<Credential>? seed]) : store = [...?seed];
  final List<Credential> store;

  @override
  Future<List<Credential>> getAll() async => List.of(store);

  @override
  Future<void> save(Credential c) async {
    final i = store.indexWhere((e) => e.id == c.id);
    if (i == -1) {
      store.add(c);
    } else {
      store[i] = c;
    }
  }

  @override
  Future<void> delete(String id) async => store.removeWhere((e) => e.id == id);

  @override
  Future<Credential?> getById(String id) async =>
      store.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> update(Credential c) async => save(c);

  @override
  Future<List<Credential>> getByCategory(String categoryId) async =>
      store.where((c) => c.categoryId == categoryId).toList();

  @override
  Future<List<Credential>> getFavorites() async =>
      store.where((c) => c.isFavorite).toList();

  @override
  Future<List<Credential>> search(String q) async => store
      .where((c) => c.title.toLowerCase().contains(q.toLowerCase()))
      .toList();

  @override
  Future<List<PasswordHistory>> getPasswordHistory(String id) async => [];

  @override
  Future<void> setHidden(String id, bool hidden) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}

  @override
  Future<void> moveToFolder(String id, String? folderId) async {}

  @override
  Future<void> reassignFolder(String from, String? to) async {}
}

/// Wraps a real [SecurityServiceImpl] and keeps a reference to each derived key
/// so a test can assert those buffers were zeroed after export.
class _SpySecurity implements ISecurityService {
  _SpySecurity(this._inner);
  final ISecurityService _inner;

  final List<Uint8List> derivedKeys = [];

  @override
  Future<Uint8List> deriveKey({
    required String password,
    required String saltBase64,
    required int memory,
    required int iterations,
    required int parallelism,
  }) async {
    final key = await _inner.deriveKey(
      password: password,
      saltBase64: saltBase64,
      memory: memory,
      iterations: iterations,
      parallelism: parallelism,
    );
    derivedKeys.add(key); // same buffer the service will zero in place
    return key;
  }

  @override
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List keyBytes) =>
      _inner.encrypt(plaintext, keyBytes);

  @override
  Future<Uint8List> decrypt(Uint8List cipherBlob, Uint8List keyBytes) =>
      _inner.decrypt(cipherBlob, keyBytes);

  @override
  Future<String> generateSaltBase64() => _inner.generateSaltBase64();

  @override
  Future<String> createVerificationData(Uint8List keyBytes) =>
      _inner.createVerificationData(keyBytes);

  @override
  Future<bool> verifyKey(Uint8List keyBytes, String verificationData) =>
      _inner.verifyKey(keyBytes, verificationData);

  @override
  Future<Uint8List> sha256(Uint8List data) => _inner.sha256(data);
}

Credential _cred(
  String id,
  CredentialType type, {
  String? folder,
  String? password,
}) =>
    Credential(
      id: id,
      type: type,
      title: 'title-$id',
      username: 'user-$id',
      password: password ?? 'secret-$id',
      categoryId: folder,
      createdAt: DateTime(2021, 1, 1),
      updatedAt: DateTime(2021, 6, 1),
    );

Folder _folder(String id, String name) =>
    Folder(id: id, name: name, createdAt: DateTime(2021));

void main() {
  const password = 'backup-pass-123';

  late SecurityServiceImpl security;
  late SessionManager session;
  late Directory tmp;

  setUp(() async {
    security = SecurityServiceImpl();
    session = SessionManager();
    tmp = await Directory.systemTemp.createTemp('skvault_test');
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  test('round-trip export -> import preserves credentials, folders and types',
      () async {
    final seedCreds = [
      _cred('1', CredentialType.password, folder: 'f-work'),
      _cred('2', CredentialType.totp,
          folder: 'f-personal', password: 'JBSWY3DPEHPK3PXP'),
      _cred('3', CredentialType.apiKey), // unfiled
      _cred('4', CredentialType.secureNote, folder: 'f-work'),
    ];

    final srcCred = _MutableCredRepo(seedCreds);
    final srcFolder =
        FakeFolderRepository([_folder('f-work', 'Work'), _folder('f-personal', 'Personal')]);
    final exportSvc = VaultExportService(srcCred, srcFolder, security, session);

    final path = await exportSvc.exportVaultToDirectory(
      exportPassword: password,
      directoryPath: tmp.path,
    );
    final bytes = await File(path).readAsBytes();
    expect(bytes.length, greaterThan(40)); // magic(8) + salt(32) + blob

    // Import into a fresh, empty vault.
    final dstCred = _MutableCredRepo();
    final dstFolder = FakeFolderRepository([]);
    final importSvc = VaultExportService(dstCred, dstFolder, security, session);

    final backup =
        await importSvc.decryptBackup(fileBytes: bytes, exportPassword: password);
    expect(backup.credentials, hasLength(4));
    expect(backup.folders, hasLength(2));

    final result = await importSvc.performSelectiveImport(
      backup: backup,
      mode: ImportMode.merge,
      typeFilter: CredentialType.values.toSet(),
      folderFilter: {'f-work', 'f-personal', kNoFolderFilterId},
    );

    expect(result.success, isTrue);
    expect(result.credentialsImported, 4);
    expect(dstCred.store, hasLength(4));
    expect(dstFolder.folders, hasLength(2));

    final imported2 = dstCred.store.firstWhere((c) => c.id == '2');
    expect(imported2.type, CredentialType.totp);
    expect(imported2.password, 'JBSWY3DPEHPK3PXP');
    expect(imported2.categoryId, 'f-personal');

    final imported3 = dstCred.store.firstWhere((c) => c.id == '3');
    expect(imported3.type, CredentialType.apiKey);
    expect(imported3.categoryId, isNull);
  });

  test('selective import can restrict by type', () async {
    final srcCred = _MutableCredRepo([
      _cred('1', CredentialType.password),
      _cred('2', CredentialType.totp, password: 'JBSWY3DPEHPK3PXP'),
    ]);
    final exportSvc =
        VaultExportService(srcCred, FakeFolderRepository([]), security, session);
    final path = await exportSvc.exportVaultToDirectory(
        exportPassword: password, directoryPath: tmp.path);
    final bytes = await File(path).readAsBytes();

    final dstCred = _MutableCredRepo();
    final importSvc =
        VaultExportService(dstCred, FakeFolderRepository([]), security, session);
    final backup =
        await importSvc.decryptBackup(fileBytes: bytes, exportPassword: password);

    final result = await importSvc.performSelectiveImport(
      backup: backup,
      mode: ImportMode.merge,
      typeFilter: {CredentialType.totp},
      folderFilter: {kNoFolderFilterId},
    );

    expect(result.credentialsImported, 1);
    expect(dstCred.store.single.type, CredentialType.totp);
  });

  test('decrypt with a wrong password fails clearly', () async {
    final svc = VaultExportService(
      _MutableCredRepo([_cred('1', CredentialType.password)]),
      FakeFolderRepository([]),
      security,
      session,
    );
    final path = await svc.exportVaultToDirectory(
        exportPassword: password, directoryPath: tmp.path);
    final bytes = await File(path).readAsBytes();

    expect(
      () => svc.decryptBackup(fileBytes: bytes, exportPassword: 'wrong-password'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('a corrupt / non-skvault file is rejected with a clear error', () async {
    final svc = VaultExportService(
        _MutableCredRepo(), FakeFolderRepository([]), security, session);
    final garbage = Uint8List.fromList(List.filled(64, 7));
    expect(
      () => svc.decryptBackup(fileBytes: garbage, exportPassword: password),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('export zeroes the derived key after use', () async {
    final spy = _SpySecurity(security);
    final svc = VaultExportService(
      _MutableCredRepo([_cred('1', CredentialType.password)]),
      FakeFolderRepository([]),
      spy,
      session,
    );

    await svc.exportVaultToDirectory(
        exportPassword: password, directoryPath: tmp.path);

    expect(spy.derivedKeys, isNotEmpty);
    for (final key in spy.derivedKeys) {
      expect(key.every((b) => b == 0), isTrue,
          reason: 'the export key must be zeroed in RAM after use');
    }
  });
}
