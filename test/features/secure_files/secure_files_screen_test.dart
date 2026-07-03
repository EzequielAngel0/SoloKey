import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/secure_files/application/secure_files_provider.dart';
import 'package:password_manager/features/secure_files/domain/entities/secure_file.dart';
import 'package:password_manager/features/secure_files/domain/repositories/i_secure_file_repository.dart';
import 'package:password_manager/features/secure_files/presentation/secure_files_screen.dart';

import '../../support/widget_harness.dart';

class _EmptyFolders extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

class _FakeSecureFileRepo implements ISecureFileRepository {
  @override
  Future<List<SecureFile>> getAll() async => const [];
  @override
  Future<SecureFile?> getById(String id) async => null;
  @override
  Future<SecureFile> addFile({
    required String name,
    required Uint8List bytes,
    String? note,
  }) =>
      throw UnimplementedError();
  @override
  Future<void> updateMeta(SecureFile file) async {}
  @override
  Future<Uint8List> readDecrypted(String id) => throw UnimplementedError();
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> deleteAll() async {}
}

void main() {
  testWidgets('SecureFilesScreen builds with an empty store', (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const SecureFilesScreen(),
      overrides: [
        secureFileRepositoryProvider.overrideWithValue(_FakeSecureFileRepo()),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
      ],
      surfaceSize: const Size(820, 1200),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });
}
