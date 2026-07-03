import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/folders/presentation/widgets/folder_tree.dart';
import 'package:password_manager/l10n/app_localizations.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/fake_folder_repository.dart';
import '../../support/widget_harness.dart';

Folder _f(String id, String name, {String? parent}) =>
    Folder(id: id, name: name, parentId: parent, createdAt: DateTime(2020));

Credential _c(String id, {String? categoryId}) => Credential(
      id: id,
      type: CredentialType.password,
      title: id,
      categoryId: categoryId,
      password: 'p',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  testWidgets('shows a per-folder credential count', (tester) async {
    final credRepo = FakeCredentialRepository([
      _c('a', categoryId: 'work'),
      _c('b', categoryId: 'work'),
      _c('c'), // unfiled
    ]);
    await pumpApp(
      tester,
      FolderTree(folders: [_f('work', 'Work')], selectedId: null, onSelect: (_) {}),
      overrides: [
        folderRepositoryProvider
            .overrideWithValue(FakeFolderRepository([_f('work', 'Work')])),
        getCredentialsUseCaseProvider
            .overrideWithValue(GetCredentialsUseCase(credRepo)),
        saveCredentialUseCaseProvider
            .overrideWithValue(SaveCredentialUseCase(credRepo)),
      ],
      surfaceSize: const Size(360, 640),
    );
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget); // Work has 2 credentials
    expect(find.text('1'), findsOneWidget); // vault root has 1 unfiled
  });

  testWidgets('a selected folder exposes management actions on desktop',
      (tester) async {
    final credRepo = FakeCredentialRepository([]);
    await pumpApp(
      tester,
      // Selected → the "⋯" management button is shown for the row.
      FolderTree(
          folders: [_f('work', 'Work')], selectedId: 'work', onSelect: (_) {}),
      overrides: [
        folderRepositoryProvider
            .overrideWithValue(FakeFolderRepository([_f('work', 'Work')])),
        getCredentialsUseCaseProvider
            .overrideWithValue(GetCredentialsUseCase(credRepo)),
        saveCredentialUseCaseProvider
            .overrideWithValue(SaveCredentialUseCase(credRepo)),
      ],
      surfaceSize: const Size(360, 640),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.folderNewSubfolder), findsOneWidget);
    expect(find.text(l10n.folderRename), findsOneWidget);
    expect(find.text(l10n.commonDelete), findsOneWidget);
  });
}
