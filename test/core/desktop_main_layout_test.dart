import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/presentation/layouts/desktop_main_layout.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/sync/application/sync_status_provider.dart';

import '../support/fake_credential_repository.dart';
import '../support/widget_harness.dart';

class _EmptyFolders extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

/// Fixed idle sync status so the sidebar badge renders without the sync engine.
class _IdleSyncStatus extends SyncStatus {
  @override
  SyncStatusState build() => const SyncStatusState(phase: SyncPhase.idle);
}

/// Forces the "syncing" phase so the sidebar badge (a spinner) is assertable
/// without a live sync engine.
class _SyncingSyncStatus extends SyncStatus {
  @override
  SyncStatusState build() => const SyncStatusState(phase: SyncPhase.syncing);
}

class _SeededFolders extends FoldersNotifier {
  _SeededFolders(this._folders);
  final List<Folder> _folders;
  @override
  Future<List<Folder>> build() async => _folders;
}

Folder _folder(String id, String name) =>
    Folder(id: id, name: name, createdAt: DateTime(2021));

Credential _c(String id, String title, {bool favorite = false}) => Credential(
      id: id,
      type: CredentialType.password,
      title: title,
      password: 'p',
      isFavorite: favorite,
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
        syncStatusProvider.overrideWith(_IdleSyncStatus.new),
      ],
      // Desktop breakpoint: give it a wide window.
      surfaceSize: const Size(1300, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.text('GitHub'), findsWidgets);
  });

  testWidgets('sidebar groups nav items under section headers',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const DesktopMainLayout(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
            FakeCredentialRepository([_c('1', 'GitHub'), _c('2', 'GitLab')]))),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
        syncStatusProvider.overrideWith(_IdleSyncStatus.new),
      ],
      surfaceSize: const Size(1300, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The three section headers are the uppercased localized titles.
    expect(find.text('VAULT'), findsOneWidget);
    expect(find.text('SECURITY'), findsOneWidget);
    expect(find.text('DEVICES'), findsOneWidget);
    // Settings + Lock live in the footer, still reachable.
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Lock'), findsWidgets);
  });

  testWidgets('wide window shows list + detail (two panes)', (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const DesktopMainLayout(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
            FakeCredentialRepository([_c('1', 'GitHub')]))),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
        syncStatusProvider.overrideWith(_IdleSyncStatus.new),
      ],
      surfaceSize: const Size(1300, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Detail empty-state pane is present alongside the list.
    expect(find.text('Secure Vault'), findsOneWidget);
    expect(find.text('Vault'), findsWidgets);
  });

  testWidgets('narrow window collapses to a single pane (list only)',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const DesktopMainLayout(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(GetCredentialsUseCase(
            FakeCredentialRepository([_c('1', 'GitHub')]))),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
        syncStatusProvider.overrideWith(_IdleSyncStatus.new),
      ],
      // 800 - 240 (sidebar) - 1 (divider) = 559 < 640 → single pane.
      surfaceSize: const Size(800, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Nothing selected → the list is shown and the detail pane is not built.
    expect(find.text('Vault'), findsWidgets);
    expect(find.text('Secure Vault'), findsNothing);
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
        syncStatusProvider.overrideWith(_IdleSyncStatus.new),
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

  // ── Behavioral: master-detail navigation and the sync badge ────────────────

  Future<void> pumpDesktop(
    WidgetTester tester, {
    required List<Credential> creds,
    List<Folder> folders = const [],
    SyncStatus Function() sync = _IdleSyncStatus.new,
  }) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const DesktopMainLayout(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(
            GetCredentialsUseCase(FakeCredentialRepository(creds))),
        foldersNotifierProvider.overrideWith(
            folders.isEmpty ? _EmptyFolders.new : () => _SeededFolders(folders)),
        syncStatusProvider.overrideWith(sync),
      ],
      surfaceSize: const Size(1300, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('the Favorites nav item filters the list to favorites only',
      (tester) async {
    await pumpDesktop(tester, creds: [
      _c('1', 'GitHub'),
      _c('2', 'Netflix', favorite: true),
    ]);
    // Both are visible on the Vault tab.
    expect(find.text('GitHub'), findsWidgets);
    expect(find.text('Netflix'), findsWidgets);

    await tester.tap(find.text('Favourites'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Only the favorite remains once the Favorites destination is active.
    expect(find.text('Netflix'), findsWidgets);
    expect(find.text('GitHub'), findsNothing);
  });

  testWidgets('the Folders nav item swaps the middle pane for the folder tree',
      (tester) async {
    await pumpDesktop(
      tester,
      creds: [_c('1', 'GitHub')],
      folders: [_folder('f1', 'Work'), _folder('f2', 'Personal')],
    );

    await tester.tap(find.text('Folders'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The tree lists the folders; the credential list is no longer the pane.
    expect(find.text('Work'), findsWidgets);
    expect(find.text('Personal'), findsWidgets);
  });

  testWidgets('selecting a credential opens its detail in the right pane',
      (tester) async {
    await pumpDesktop(tester, creds: [_c('1', 'GitHub')]);

    // Right pane starts on the empty state.
    expect(find.text('Secure Vault'), findsOneWidget);

    await tester.tap(find.text('GitHub').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The empty state is replaced by the credential detail (its title now shows
    // in both the list and the detail app bar).
    expect(find.text('Secure Vault'), findsNothing);
    expect(find.text('GitHub'), findsWidgets);
  });

  testWidgets('the sidebar shows a spinner badge while syncing', (tester) async {
    // Idle: no spinner anywhere (the vault list is already loaded).
    await pumpDesktop(tester, creds: [_c('1', 'GitHub')]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('syncing phase renders the sync badge spinner', (tester) async {
    await pumpDesktop(
      tester,
      creds: [_c('1', 'GitHub')],
      sync: _SyncingSyncStatus.new,
    );
    // The only spinner on screen is the Sync nav item's badge.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
