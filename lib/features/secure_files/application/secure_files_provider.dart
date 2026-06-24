import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/secure_file.dart';
import '../domain/repositories/i_secure_file_repository.dart';

part 'secure_files_provider.g.dart';

@riverpod
class SecureFilesNotifier extends _$SecureFilesNotifier {
  @override
  Future<List<SecureFile>> build() async {
    return ref.read(secureFileRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(secureFileRepositoryProvider).getAll(),
    );
  }

  Future<SecureFile> addFile({
    required String name,
    required Uint8List bytes,
    String? note,
  }) async {
    final file = await ref.read(secureFileRepositoryProvider).addFile(
          name: name,
          bytes: bytes,
          note: note,
        );
    await refresh();
    return file;
  }

  Future<void> deleteFile(String id) async {
    await ref.read(secureFileRepositoryProvider).delete(id);
    await refresh();
  }

  Future<void> rename(SecureFile file, String newName) async {
    await ref
        .read(secureFileRepositoryProvider)
        .updateMeta(file.copyWith(name: newName));
    await refresh();
  }

  Future<void> moveToFolder(SecureFile file, String? folderId) async {
    await ref
        .read(secureFileRepositoryProvider)
        .updateMeta(file.copyWith(folderId: folderId));
    await refresh();
  }

  Future<void> toggleFavorite(SecureFile file) async {
    await ref
        .read(secureFileRepositoryProvider)
        .updateMeta(file.copyWith(isFavorite: !file.isFavorite));
    await refresh();
  }
}

@riverpod
ISecureFileRepository secureFileRepository(Ref ref) {
  throw UnimplementedError('Register via get_it override');
}
