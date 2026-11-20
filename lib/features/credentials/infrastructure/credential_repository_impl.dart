import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../core/infrastructure/vault/vault_store.dart';
import '../../../core/services/rotation_schedule.dart';
import '../domain/entities/category.dart';
import '../domain/entities/credential.dart';
import '../domain/entities/password_history.dart';
import '../domain/repositories/i_credential_repository.dart';
import 'credential_dto.dart';

/// Credenciales en la boveda v2 (NUC-2): un registro `credential` por entrada y un `history` por version guardada.
/// El nucleo cifra cada registro entero; aqui solo se arma y se lee el JSON.
@LazySingleton(as: ICredentialRepository)
class CredentialRepositoryImpl implements ICredentialRepository {
  const CredentialRepositoryImpl(this._vault, this._rotation);

  final VaultStore _vault;
  final RotationSchedule _rotation;

  /// Ultimas versiones que se guardan por credencial (como la v1).
  static const _historyKeep = 10;

  Future<List<Credential>> _all() async {
    final list = <Credential>[];
    for (final m in await _vault.list(RecordKind.credential)) {
      try {
        list.add(CredentialDto.fromRecord(m));
      } catch (_) {
        // Un registro que no se entiende no tumba la boveda entera.
      }
    }
    // Mismo orden que la v1: orden manual y, a igualdad, la mas nueva primero.
    list.sort((a, b) {
      final o = a.sortOrder.compareTo(b.sortOrder);
      return o != 0 ? o : b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  Future<void> _put(Iterable<Credential> credentials) async {
    await _vault.put(RecordKind.credential, {
      for (final c in credentials) c.id: CredentialDto.toRecord(c),
    });
    await _rotation.rebuild(await _all());
  }

  @override
  Future<List<Credential>> getAll() => _all();

  @override
  Future<Credential?> getById(String id) async {
    final m = await _vault.get(RecordKind.credential, id);
    return m == null ? null : CredentialDto.fromRecord(m);
  }

  @override
  Future<void> save(Credential credential) async {
    await _put([credential]);
    final historyId = const Uuid().v4();
    await _vault.put(RecordKind.history, {
      historyId: {
        ...CredentialDto.toPayload(credential).toJson(),
        'id': historyId,
        'credentialId': credential.id,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
    });
    final old = (await _historyOf(credential.id)).skip(_historyKeep);
    for (final h in old) {
      await _vault.remove(h['id'] as String);
    }
  }

  @override
  Future<void> update(Credential credential) => save(credential);

  @override
  Future<void> delete(String id) async {
    await _vault.remove(id);
    await _rotation.rebuild(await _all());
  }

  @override
  Future<List<Credential>> getByCategory(String categoryId) async =>
      (await _all()).where((c) => c.categoryId == categoryId).toList();

  @override
  Future<List<Credential>> getFavorites() async =>
      (await _all()).where((c) => c.isFavorite).toList();

  @override
  Future<List<Credential>> search(String query) async {
    final q = query.toLowerCase();
    return (await _all())
        .where((c) => c.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<void> setHidden(String id, bool hidden) async {
    final c = await getById(id);
    if (c != null) await _put([c.copyWith(isHidden: hidden)]);
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    final byId = {for (final c in await _all()) c.id: c};
    await _put([
      for (var i = 0; i < orderedIds.length; i++)
        if (byId[orderedIds[i]] != null)
          byId[orderedIds[i]]!.copyWith(sortOrder: i),
    ]);
  }

  @override
  Future<void> moveToFolder(String id, String? folderId) async {
    final c = await getById(id);
    if (c != null) {
      await _put([c.copyWith(categoryId: folderId, updatedAt: DateTime.now())]);
    }
  }

  @override
  Future<void> reassignFolder(String fromFolderId, String? toFolderId) async {
    final now = DateTime.now();
    await _put([
      for (final c in await _all())
        if (c.categoryId == fromFolderId)
          c.copyWith(categoryId: toFolderId, updatedAt: now),
    ]);
  }

  /// Historial de [credentialId], el mas nuevo primero.
  Future<List<Map<String, dynamic>>> _historyOf(String credentialId) async {
    final list = (await _vault.list(RecordKind.history))
        .where((h) => h['credentialId'] == credentialId)
        .toList()
      ..sort((a, b) =>
          (b['createdAt'] as num).compareTo(a['createdAt'] as num));
    return list;
  }

  @override
  Future<List<PasswordHistory>> getPasswordHistory(String credentialId) async =>
      [
        for (final h in (await _historyOf(credentialId)).take(_historyKeep))
          PasswordHistory(
            id: h['id'] as String,
            password: h['password'] as String? ?? '',
            createdAt: DateTime.fromMillisecondsSinceEpoch(
                (h['createdAt'] as num).toInt()),
          ),
      ];
}

@LazySingleton(as: ICategoryRepository)
class CategoryRepositoryImpl implements ICategoryRepository {
  const CategoryRepositoryImpl(this._vault);

  final VaultStore _vault;

  @override
  Future<List<Category>> getAll() async =>
      [for (final m in await _vault.list(RecordKind.category)) _from(m)];

  @override
  Future<Category?> getById(String id) async {
    final m = await _vault.get(RecordKind.category, id);
    return m == null ? null : _from(m);
  }

  @override
  Future<void> save(Category category) =>
      _vault.put(RecordKind.category, {category.id: _to(category)});

  @override
  Future<void> delete(String id) => _vault.remove(id);

  Category _from(Map<String, dynamic> m) => Category(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        icon: m['icon'] as String? ?? '',
        createdAt:
            DateTime.fromMillisecondsSinceEpoch((m['createdAt'] as num).toInt()),
      );

  Map<String, dynamic> _to(Category c) => {
        'id': c.id,
        'name': c.name,
        'icon': c.icon,
        'createdAt': c.createdAt.millisecondsSinceEpoch,
      };
}
