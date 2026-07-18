import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:password_manager/core/services/biometric_auth_service.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/secure_files/application/secure_files_provider.dart';
import 'package:password_manager/features/secure_files/domain/entities/secure_file.dart';
import 'package:password_manager/features/secure_files/presentation/secure_files_screen.dart';
import 'package:password_manager/shared/widgets/empty_state.dart';

import '../../support/fake_file_picker.dart';
import '../../support/fake_secure_file_repository.dart';
import '../../support/widget_harness.dart';

class _EmptyFolders extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

/// Fake biometric service (registered in get_it, since `AuthHelper.requireAuth`
/// resolves it there). Flip [result] to model a granted/denied prompt.
class _FakeBiometric extends BiometricAuthService {
  bool result = true;
  int calls = 0;
  @override
  Future<bool> authenticate({required String reason}) async {
    calls++;
    return result;
  }
}

SecureFile _file(String id, String name, {String? mime}) {
  final now = DateTime(2020, 6, 1);
  return SecureFile(
    id: id,
    name: name,
    sizeBytes: 2048,
    storedFileName: '$id.enc',
    mimeHint: mime,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late _FakeBiometric bio;

  setUp(() {
    bio = _FakeBiometric();
    GetIt.I.registerSingleton<BiometricAuthService>(bio);
  });
  tearDown(() => GetIt.I.reset());

  Future<FakeSecureFileRepository> pumpFiles(
    WidgetTester tester, {
    List<SecureFile> seed = const [],
  }) async {
    tolerateInkHiddenPaintWarnings();
    final repo = FakeSecureFileRepository(seed);
    await pumpApp(
      tester,
      const SecureFilesScreen(),
      overrides: [
        secureFileRepositoryProvider.overrideWithValue(repo),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
      ],
      surfaceSize: const Size(820, 1200),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return repo;
  }

  testWidgets('empty store shows the EmptyState', (tester) async {
    await pumpFiles(tester);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No files yet'), findsOneWidget);
  });

  testWidgets('lists stored files with their names', (tester) async {
    await pumpFiles(tester, seed: [
      _file('1', 'photo.png', mime: 'png'),
      _file('2', 'creds.json', mime: 'json'),
    ]);
    expect(find.text('photo.png'), findsOneWidget);
    expect(find.text('creds.json'), findsOneWidget);
  });

  testWidgets('adding from the picker appends the encrypted file to the list',
      (tester) async {
    FilePicker.platform =
        FakeFilePicker(pickResult: pickedFile('notes.txt', Uint8List(64)));
    final repo = await pumpFiles(tester);

    expect(find.byType(EmptyState), findsOneWidget);

    await tester.tap(find.text('Add file'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(repo.addFileCalls, 1);
    expect(repo.store.single.name, 'notes.txt');
    expect(find.text('notes.txt'), findsOneWidget);
  });

  testWidgets('a denied auth leaves the file undeleted', (tester) async {
    bio.result = false;
    final repo = await pumpFiles(tester, seed: [_file('1', 'key.pem', mime: 'pem')]);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Auth was requested and refused → no confirm dialog, file still present.
    expect(bio.calls, 1);
    expect(find.text('Delete file?'), findsNothing);
    expect(repo.store, hasLength(1));
    expect(find.text('key.pem'), findsOneWidget);
  });

  testWidgets('delete removes the file after auth + confirmation',
      (tester) async {
    bio.result = true;
    final repo = await pumpFiles(tester, seed: [_file('1', 'key.pem', mime: 'pem')]);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Confirmation dialog is up (auth passed).
    expect(find.text('Delete file?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repo.store, isEmpty);
    expect(find.text('key.pem'), findsNothing);
    expect(find.byType(EmptyState), findsOneWidget);
  });

  group('reveal is gated behind auth', () {
    testWidgets('export decrypts only after a granted prompt', (tester) async {
      bio.result = true;
      FilePicker.platform = FakeFilePicker(savePath: null); // user cancels save
      final repo =
          await pumpFiles(tester, seed: [_file('1', 'creds.json', mime: 'json')]);

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export / Save'));
      await tester.pumpAndSettle();

      expect(bio.calls, 1);
      expect(repo.readDecryptedCalls, 1);
    });

    testWidgets('a denied prompt never decrypts', (tester) async {
      bio.result = false;
      final repo =
          await pumpFiles(tester, seed: [_file('1', 'creds.json', mime: 'json')]);

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export / Save'));
      await tester.pumpAndSettle();

      expect(bio.calls, 1);
      expect(repo.readDecryptedCalls, 0);
    });
  });
}
