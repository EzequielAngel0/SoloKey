import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/presentation/layouts/desktop_layout_state.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/widgets/command_palette.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/widget_harness.dart';

Credential _c(String id, String title, {String? user}) => Credential(
      id: id,
      type: CredentialType.password,
      title: title,
      username: user,
      password: 'p',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

List<Override> _overrides() => [
      getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
          FakeCredentialRepository([
        _c('1', 'GitHub', user: 'octocat'),
        _c('2', 'GitLab'),
        _c('3', 'Netflix'),
      ]))),
    ];

/// Opens the palette from a host scaffold so `Navigator.pop` has a route to pop.
Future<ProviderContainer> _openPalette(WidgetTester tester) async {
  await pumpApp(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => CommandPalette.show(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    overrides: _overrides(),
    surfaceSize: const Size(1200, 900),
  );
  final container =
      ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('empty query shows the Actions group with quick actions',
      (tester) async {
    await _openPalette(tester);
    expect(find.text('ACTIONS'), findsOneWidget);
    expect(find.text('New credential'), findsOneWidget);
    expect(find.text('New folder'), findsOneWidget);
  });

  testWidgets('typing filters credentials and groups them', (tester) async {
    await _openPalette(tester);

    await tester.enterText(find.byType(TextField), 'git');
    await tester.pumpAndSettle();

    expect(find.text('CREDENTIALS'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('GitLab'), findsOneWidget);
    // Non-matching credential is filtered out.
    expect(find.text('Netflix'), findsNothing);
    // No action matches "git", so the Actions group is hidden.
    expect(find.text('ACTIONS'), findsNothing);
  });

  testWidgets('narrowing the query leaves a single match', (tester) async {
    await _openPalette(tester);

    await tester.enterText(find.byType(TextField), 'hub');
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('GitLab'), findsNothing);
  });

  testWidgets('arrow-down + Enter opens the second match', (tester) async {
    final container = await _openPalette(tester);

    await tester.enterText(find.byType(TextField), 'git');
    await tester.pumpAndSettle();

    // Move highlight from GitHub (0) to GitLab (1), then activate.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(container.read(desktopSelectedCredentialIdProvider), '2');
  });

  testWidgets('Enter with no navigation opens the first match', (tester) async {
    final container = await _openPalette(tester);

    await tester.enterText(find.byType(TextField), 'net');
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(container.read(desktopSelectedCredentialIdProvider), '3');
  });
}
