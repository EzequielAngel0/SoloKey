import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/presentation/layouts/desktop_main_layout.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';

import '../support/fake_credential_repository.dart';
import '../support/widget_harness.dart';

class _EmptyFolders extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

Credential _c(String id, String title) => Credential(
      id: id,
      type: CredentialType.password,
      title: title,
      password: 'p',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  testWidgets('DesktopMainLayout builds the sidebar + master-detail',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const DesktopMainLayout(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
            FakeCredentialRepository([_c('1', 'GitHub'), _c('2', 'GitLab')]))),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
      ],
      // Desktop breakpoint: give it a wide window.
      surfaceSize: const Size(1300, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.text('GitHub'), findsWidgets);
  });

  testWidgets('desktop search is debounced (>250ms) before it filters',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const DesktopMainLayout(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
            FakeCredentialRepository([_c('1', 'GitHub'), _c('2', 'GitLab')]))),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
      ],
      surfaceSize: const Size(1300, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.enterText(find.byType(TextField), 'hub');
    // Before the debounce elapses, both are still listed.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('GitLab'), findsWidgets);

    // After the debounce fires, only the match remains.
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.text('GitHub'), findsWidgets);
    expect(find.text('GitLab'), findsNothing);
  });
}
