import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/autofill/presentation/quick_fill_screen.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/widget_harness.dart';

Credential _c(String id, String title) => Credential(
      id: id,
      type: CredentialType.password,
      title: title,
      username: 'user-$id',
      password: 'p',
      website: 'https://$title.com',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  testWidgets('QuickFillScreen builds and lists credentials', (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const QuickFillScreen(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
            FakeCredentialRepository([_c('1', 'GitHub'), _c('2', 'GitLab')]))),
      ],
      surfaceSize: const Size(820, 1000),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });
}
