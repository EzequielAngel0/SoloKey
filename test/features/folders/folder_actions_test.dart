import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/folders/presentation/folder_actions.dart';
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

/// Tiny host that triggers [confirmDeleteFolder] for [folder] on button tap.
class _DeleteHost extends ConsumerWidget {
  const _DeleteHost(this.folder);
  final Folder folder;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => confirmDeleteFolder(context, ref, folder),
            child: const Text('delete'),
          ),
        ),
      );
}

void main() {
  testWidgets(
      'deleting a folder releases its credentials to the vault and re-parents '
      'its subfolders instead of orphaning them', (tester) async {
    final folders = [
      _f('work', 'Work'),
      _f('sub', 'Sub', parent: 'work'),
    ];
    final creds = [_c('gh', categoryId: 'work')];
    final folderRepo = FakeFolderRepository(folders);
    final credRepo = FakeCredentialRepository(creds);

    await pumpApp(
      tester,
      _DeleteHost(_f('work', 'Work')),
      overrides: [
        folderRepositoryProvider.overrideWithValue(folderRepo),
        getCredentialsUseCaseProvider
            .overrideWithValue(GetCredentialsUseCase(credRepo)),
        saveCredentialUseCaseProvider
            .overrideWithValue(SaveCredentialUseCase(credRepo)),
      ],
    );

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    // Root folder → single danger action ("Delete") moves everything to root.
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.commonDelete));
    await tester.pumpAndSettle();

    // Folder gone; its subfolder promoted to the vault root (not orphaned).
    expect(folders.any((f) => f.id == 'work'), isFalse);
    expect(folders.firstWhere((f) => f.id == 'sub').parentId, isNull);
    // Credential kept, just released to the vault root.
    expect(creds.single.categoryId, isNull);
  });

  testWidgets('cancelling the delete dialog changes nothing', (tester) async {
    final folders = [_f('work', 'Work')];
    final creds = [_c('gh', categoryId: 'work')];
    final folderRepo = FakeFolderRepository(folders);
    final credRepo = FakeCredentialRepository(creds);

    await pumpApp(
      tester,
      _DeleteHost(_f('work', 'Work')),
      overrides: [
        folderRepositoryProvider.overrideWithValue(folderRepo),
        getCredentialsUseCaseProvider
            .overrideWithValue(GetCredentialsUseCase(credRepo)),
        saveCredentialUseCaseProvider
            .overrideWithValue(SaveCredentialUseCase(credRepo)),
      ],
    );

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.commonCancel));
    await tester.pumpAndSettle();

    expect(folders.any((f) => f.id == 'work'), isTrue);
    expect(creds.single.categoryId, 'work');
  });
}
