import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import 'package:uuid/uuid.dart';

import '../../../core/infrastructure/database/app_database.dart';
import '../../../core/infrastructure/database/daos/category_dao.dart';
import '../../../core/infrastructure/database/daos/credential_dao.dart';
import '../../../core/infrastructure/database/daos/password_history_dao.dart';
import '../../../core/infrastructure/security/i_security_service.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../domain/entities/category.dart';
import '../domain/entities/credential.dart';
import '../domain/entities/password_history.dart';
import '../domain/repositories/i_credential_repository.dart';
import 'credential_dto.dart';

@LazySingleton(as: ICredentialRepository)
class CredentialRepositoryImpl implements ICredentialRepository {
  const CredentialRepositoryImpl(
    this._credentialDao,
    this._historyDao,
    this._securityService,
    this._sessionManager,
  );

  final CredentialDao _credentialDao;
  final PasswordHistoryDao _historyDao;
  final ISecurityService _securityService;
  final SessionManager _sessionManager;

  Uint8List get _keyBytes {
    final key = _sessionManager.getKeyCopy();
    if (key == null) throw StateError('Vault is locked');
    return key;
  }

  Future<Credential> _decryptEntry(dynamic entry) async {
    final key = _keyBytes;
    final plainBytes = await _securityService.decrypt(
      Uint8List.fromList(entry.encryptedPayload),
      key,
    );
    final payload = CredentialSensitivePayload.fromBytes(plainBytes);
    return CredentialDto.fromEntry(entry: entry, payload: payload);
  }

  /// Like [_decryptEntry] but returns null instead of throwing when a row
  /// cannot be decrypted (e.g. it was encrypted under a different master key by
  /// a past broken sync). This keeps a single corrupt row from blocking the
  /// whole vault from loading — the user can still access their other entries.
  Future<Credential?> _decryptEntryOrNull(dynamic entry) async {
    try {
      return await _decryptEntry(entry);
    } catch (_) {
      return null;
    }
  }

  Future<List<Credential>> _decryptAll(Iterable<dynamic> entries) async {
    final results = await Future.wait(entries.map(_decryptEntryOrNull));
    return results.whereType<Credential>().toList();
  }

  @override
  Future<List<Credential>> getAll() async {
    final entries = await _credentialDao.getAll();
    return _decryptAll(entries);
  }

  @override
  Future<Credential?> getById(String id) async {
    final entry = await _credentialDao.getById(id);
    if (entry == null) return null;
    return _decryptEntry(entry);
  }

  @override
  Future<void> save(Credential credential) async {
    final key = _keyBytes;
    final payload = CredentialDto.toPayload(credential);
    final encrypted = await _securityService.encrypt(payload.toBytes(), key);
    await _credentialDao.upsert(
      CredentialDto.toCompanion(
        credential: credential,
        encryptedPayload: encrypted,
      ),
    );
    await _historyDao.insert(
      PasswordHistoryEntriesCompanion.insert(
        id: const Uuid().v4(),
        credentialId: credential.id,
        encryptedPayload: encrypted,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _historyDao.pruneOld(credential.id, keep: 10);
  }

  @override
  Future<void> update(Credential credential) => save(credential);

  @override
  Future<void> delete(String id) => _credentialDao.deleteById(id);

  @override
  Future<List<Credential>> getByCategory(String categoryId) async {
    final entries = await _credentialDao.getByCategory(categoryId);
    return _decryptAll(entries);
  }

  @override
  Future<List<Credential>> getFavorites() async {
    final entries = await _credentialDao.getFavorites();
    return _decryptAll(entries);
  }

  @override
  Future<List<Credential>> search(String query) async {
    final entries = await _credentialDao.searchByTitle(query);
    return _decryptAll(entries);
  }

  @override
  Future<void> setHidden(String id, bool hidden) =>
      _credentialDao.setHidden(id, hidden);

  @override
  Future<void> reorder(List<String> orderedIds) async {
    for (var i = 0; i < orderedIds.length; i++) {
      await _credentialDao.setSortOrder(orderedIds[i], i);
    }
  }

  @override
  Future<void> moveToFolder(String id, String? folderId) =>
      _credentialDao.setCategory(
        id,
        folderId,
        DateTime.now().millisecondsSinceEpoch,
      );

  @override
  Future<void> reassignFolder(String fromFolderId, String? toFolderId) =>
      _credentialDao.reassignCategory(
        fromFolderId,
        toFolderId,
        DateTime.now().millisecondsSinceEpoch,
      );

  @override
  Future<List<PasswordHistory>> getPasswordHistory(String credentialId) async {
    final entries = await _historyDao.getByCredential(credentialId);
    final key = _keyBytes;
    
    final history = <PasswordHistory>[];
    for (final e in entries) {
      final plainBytes = await _securityService.decrypt(
        Uint8List.fromList(e.encryptedPayload),
        key,
      );
      final payload = CredentialSensitivePayload.fromBytes(plainBytes);
      history.add(PasswordHistory(
        id: e.id,
        password: payload.password ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(e.createdAt),
      ));
    }
    return history;
  }
}

@LazySingleton(as: ICategoryRepository)
class CategoryRepositoryImpl implements ICategoryRepository {
  const CategoryRepositoryImpl(this._categoryDao);

  final CategoryDao _categoryDao;

  @override
  Future<List<Category>> getAll() async {
    final entries = await _categoryDao.getAll();
    return entries.map<Category>(_fromEntry).toList();
  }

  @override
  Future<Category?> getById(String id) async {
    final entry = await _categoryDao.getById(id);
    return entry == null ? null : _fromEntry(entry);
  }

  @override
  Future<void> save(Category category) =>
      _categoryDao.upsert(_toCompanion(category));

  @override
  Future<void> delete(String id) => _categoryDao.deleteById(id);

  Category _fromEntry(CategoryEntry e) => Category(
        id: e.id,
        name: e.name,
        icon: e.icon,
        createdAt: DateTime.fromMillisecondsSinceEpoch(e.createdAt),
      );

  CategoryEntriesCompanion _toCompanion(Category c) =>
      CategoryEntriesCompanion.insert(
        id: c.id,
        name: c.name,
        icon: c.icon,
        createdAt: c.createdAt.millisecondsSinceEpoch,
      );
}
