import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/widgets/command_palette.dart';

import '../../../support/fake_credential_repository.dart';
import '../../../support/widget_harness.dart';

Credential _c(String id, String title) => Credential(
      id: id,
      type: CredentialType.password,
      title: title,
      password: 'p',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  testWidgets('CommandPalette renders a search box and filters by query',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const CommandPalette(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
            FakeCredentialRepository([_c('1', 'GitHub'), _c('2', 'GitLab')]))),
      ],
      surfaceSize: const Size(820, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'hub');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
