import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/passkeys/presentation/passkeys_screen.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/widget_harness.dart';

Credential _passkey(String id, String title) => Credential(
      id: id,
      type: CredentialType.passkey,
      title: title,
      password: 'handle',
      passkeyMetadata: PasskeyMetadata(rpId: '$title.com', credentialId: 'c-$id'),
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

Future<void> pumpPasskeys(WidgetTester tester, List<Credential> creds) async {
  tolerateInkHiddenPaintWarnings();
  await pumpApp(
    tester,
    const PasskeysScreen(),
    overrides: [
      getCredentialsUseCaseProvider
          .overrideWithValue(GetCredentialsUseCase(FakeCredentialRepository(creds))),
    ],
    surfaceSize: const Size(820, 1200),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('shows the empty state when there are no passkeys',
      (tester) async {
    await pumpPasskeys(tester, const []);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lists passkey credentials', (tester) async {
    await pumpPasskeys(tester, [_passkey('1', 'Example'), _passkey('2', 'Acme')]);
    expect(find.text('Example'), findsWidgets);
    expect(find.text('Acme'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens details with a copyable credential id', (tester) async {
    await pumpPasskeys(tester, [_passkey('1', 'Example')]);
    await tester.tap(find.text('Example').first);
    await tester.pumpAndSettle();
    expect(find.text('Example.com'), findsWidgets);
    expect(find.text('c-1'), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
