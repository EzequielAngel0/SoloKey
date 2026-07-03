import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/home_screen.dart';
import 'package:password_manager/features/credentials/presentation/widgets/credential_list_widget.dart';
import 'package:password_manager/shared/widgets/empty_state.dart';
import 'package:password_manager/shared/widgets/shimmer_loader.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/widget_harness.dart';

Credential _c(String id, String title,
        {CredentialType type = CredentialType.password}) =>
    Credential(
      id: id,
      type: type,
      title: title,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    List<Credential> creds = const [],
    Object? failWith,
    bool loadForever = false,
  }) async {
    final repo = FakeCredentialRepository(creds,
        failWith: failWith, loadForever: loadForever);
    await pumpApp(
      tester,
      const MobileHomeScreen(),
      overrides: [
        getCredentialsUseCaseProvider
            .overrideWithValue(GetCredentialsUseCase(repo)),
      ],
      surfaceSize: const Size(430, 1200),
    );
  }

  /// Advances a couple of frames so the async vault resolves (without settling —
  /// ShimmerLoader/animations never settle).
  Future<void> resolve(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('renders the vault list once loaded', (tester) async {
    await pumpHome(tester, creds: [_c('1', 'GitHub'), _c('2', 'GitLab')]);
    await resolve(tester);
    expect(find.byType(CredentialListWidget), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('GitLab'), findsOneWidget);
  });

  testWidgets('shows the shimmer while the vault is loading', (tester) async {
    await pumpHome(tester, loadForever: true);
    await tester.pump(); // one frame, do NOT settle (shimmer animates forever)
    expect(find.byType(ShimmerLoader), findsOneWidget);
    expect(find.byType(CredentialListWidget), findsNothing);
  });

  testWidgets('shows the error branch when loading fails', (tester) async {
    await pumpHome(tester, failWith: Exception('boom'));
    await resolve(tester);
    expect(find.byType(CredentialListWidget), findsNothing);
    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('empty vault shows the "vault is empty" state', (tester) async {
    await pumpHome(tester, creds: const []);
    await resolve(tester);
    expect(find.text('Your vault is empty'), findsOneWidget);
  });

  testWidgets('the Passwords filter chip narrows the list by type',
      (tester) async {
    await pumpHome(tester, creds: [
      _c('1', 'GitHub'),
      _c('2', 'MyNote', type: CredentialType.secureNote),
    ]);
    await resolve(tester);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('MyNote'), findsOneWidget);

    await tester.tap(find.text('Passwords'));
    await tester.pump();
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('MyNote'), findsNothing);
  });

  testWidgets('search is debounced and filters to matches (no-results state)',
      (tester) async {
    await pumpHome(tester, creds: [_c('1', 'GitHub'), _c('2', 'GitLab')]);
    await resolve(tester);

    await tester.enterText(find.byType(TextField), 'hub');
    // Before the 250ms debounce elapses, both are still shown.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('GitLab'), findsOneWidget);

    // After the debounce fires, only the match remains.
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('GitLab'), findsNothing);
  });

  testWidgets('a search with no matches shows the "No results" empty state',
      (tester) async {
    await pumpHome(tester, creds: [_c('1', 'GitHub')]);
    await resolve(tester);

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No results'), findsOneWidget);
  });
}
