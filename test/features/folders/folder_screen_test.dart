import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/folders/presentation/folder_screen.dart';
import 'package:password_manager/l10n/app_localizations.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/widget_harness.dart';

class _Folders extends FoldersNotifier {
  _Folders(this.items);
  final List<Folder> items;
  @override
  Future<List<Folder>> build() async => items;
}

Folder _f(String id, String name, {String? parent}) =>
    Folder(id: id, name: name, parentId: parent, createdAt: DateTime(2020));

Credential _c(String id, String title, {String? categoryId}) => Credential(
      id: id,
      type: CredentialType.password,
      title: title,
      categoryId: categoryId,
      password: 'p',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  testWidgets('FolderScreen renders a folder with its subfolder and credential',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const FolderScreen(folderId: 'work'),
      overrides: [
        foldersNotifierProvider.overrideWith(
            () => _Folders([_f('work', 'Work'), _f('sub', 'Sub', parent: 'work')])),
        getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
            FakeCredentialRepository([_c('1', 'GitHub', categoryId: 'work')]))),
      ],
      surfaceSize: const Size(440, 1200),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.text('GitHub'), findsWidgets);
    // The empty "Sub" subfolder shows its localized item count.
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.folderItemCount(0)), findsOneWidget);
  });
}
