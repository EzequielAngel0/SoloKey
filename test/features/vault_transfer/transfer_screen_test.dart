import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/vault_transfer/presentation/transfer_screen.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/widget_harness.dart';

class _EmptyFolders extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

Credential _c(String id) => Credential(
      id: id,
      type: CredentialType.password,
      title: 'cred-$id',
      password: 'p',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  testWidgets('TransferScreen builds with its export/import tabs',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const TransferScreen(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(
            GetCredentialsUseCase(FakeCredentialRepository([_c('1'), _c('2')]))),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
      ],
      surfaceSize: const Size(820, 1400),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(TabBar), findsOneWidget);
  });
}
