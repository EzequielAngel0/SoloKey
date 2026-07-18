import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:password_manager/core/infrastructure/security/i_security_service.dart';
import 'package:password_manager/core/infrastructure/security/session_manager.dart';
import 'package:password_manager/core/services/vault_export_service.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/vault_transfer/presentation/transfer_screen.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/fake_file_picker.dart';
import '../../support/fake_folder_repository.dart';
import '../../support/widget_harness.dart';

class _EmptyFolders extends FoldersNotifier {
  @override
  Future<List<Folder>> build() async => const [];
}

/// ISecurityService stub: every member throws, because the export-service seam
/// below overrides all real crypto entry points — none of these run.
class _NoopSecurity implements ISecurityService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('security not used in transfer widget tests');
}

/// Seam over [VaultExportService]: captures what the screen asks it to export
/// and returns canned results for import, so the flow is exercised end-to-end
/// without touching `share_plus`/`file_picker` crypto or the real vault.
///
/// Zero-Print: it stores ids/passwords for assertions but never emits secrets.
class _FakeExportService extends VaultExportService {
  _FakeExportService()
      : super(FakeCredentialRepository(const []), FakeFolderRepository([]),
            _NoopSecurity(), SessionManager());

  // Export capture.
  int exportCalls = 0;
  String? lastExportPassword;
  Set<String>? lastCredentialIds;

  // Import canned data + capture.
  DecryptedBackup decryptResult =
      const DecryptedBackup(credentials: [], folders: []);
  int importCalls = 0;
  ImportMode? lastImportMode;
  ImportResult importResult = const ImportResult(success: true, message: 'ok');

  @override
  Future<ExportSummary?> exportVault({
    required String exportPassword,
    Set<CredentialType>? typeFilter,
    Set<String>? folderFilter,
    Set<String>? credentialIds,
  }) async {
    exportCalls++;
    lastExportPassword = exportPassword;
    lastCredentialIds = credentialIds == null ? null : {...credentialIds};
    return ExportSummary(
      totalCredentials: credentialIds?.length ?? 0,
      totalFolders: 0,
      countsByType: const {},
    );
  }

  @override
  Future<DecryptedBackup> decryptBackup({
    required Uint8List fileBytes,
    required String exportPassword,
  }) async =>
      decryptResult;

  @override
  Future<ImportResult> performSelectiveImport({
    required DecryptedBackup backup,
    required ImportMode mode,
    required Set<CredentialType> typeFilter,
    required Set<String> folderFilter,
  }) async {
    importCalls++;
    lastImportMode = mode;
    return importResult;
  }
}

Credential _c(String id, {CredentialType type = CredentialType.password}) =>
    Credential(
      id: id,
      type: type,
      title: 'cred-$id',
      password: 'p',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  late _FakeExportService fakeExport;

  setUp(() {
    fakeExport = _FakeExportService();
    GetIt.I.registerSingleton<VaultExportService>(fakeExport);
  });
  tearDown(() => GetIt.I.reset());

  Future<void> pumpTransfer(WidgetTester tester,
      {List<Credential> creds = const []}) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const TransferScreen(),
      overrides: [
        getCredentialsUseCaseProvider.overrideWithValue(
            GetCredentialsUseCase(FakeCredentialRepository(creds))),
        foldersNotifierProvider.overrideWith(_EmptyFolders.new),
      ],
      surfaceSize: const Size(820, 1400),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('renders the export/import tabs', (tester) async {
    await pumpTransfer(tester, creds: [_c('1'), _c('2')]);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Export vault'), findsOneWidget);
  });

  group('export', () {
    testWidgets('exports exactly the selected credentials with the password',
        (tester) async {
      await pumpTransfer(tester, creds: [_c('1'), _c('2')]);

      await tester.enterText(find.byType(TextField).first, 's3cret');
      await tester.tap(find.text('Select all'));
      await tester.pump();

      await tester.ensureVisible(find.text('Export vault'));
      await tester.tap(find.text('Export vault'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(fakeExport.exportCalls, 1);
      expect(fakeExport.lastCredentialIds, {'1', '2'});
      expect(fakeExport.lastExportPassword, 's3cret');
      // Success result card confirms the summary made it back to the UI.
      expect(find.text('Export completed'), findsOneWidget);
    });

    testWidgets('a partial selection exports only the picked ids',
        (tester) async {
      await pumpTransfer(tester, creds: [_c('1'), _c('2'), _c('3')]);

      await tester.enterText(find.byType(TextField).first, 'pw');
      // Expand the unfiled group, then tick only the first credential.
      await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
      await tester.pump();
      await tester.tap(find.text('cred-1'));
      await tester.pump();

      await tester.ensureVisible(find.text('Export vault'));
      await tester.tap(find.text('Export vault'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(fakeExport.exportCalls, 1);
      expect(fakeExport.lastCredentialIds, {'1'});
    });

    testWidgets('refuses to export without a password', (tester) async {
      await pumpTransfer(tester, creds: [_c('1')]);

      await tester.tap(find.text('Select all'));
      await tester.pump();
      await tester.ensureVisible(find.text('Export vault'));
      await tester.tap(find.text('Export vault'));
      await tester.pump();

      expect(fakeExport.exportCalls, 0);
      expect(find.text('Enter an export password'), findsOneWidget);
    });

    testWidgets('refuses to export with nothing selected', (tester) async {
      await pumpTransfer(tester, creds: [_c('1')]);

      await tester.enterText(find.byType(TextField).first, 'pw');
      await tester.ensureVisible(find.text('Export vault'));
      await tester.tap(find.text('Export vault'));
      await tester.pump();

      expect(fakeExport.exportCalls, 0);
      expect(find.text('Select at least one credential'), findsOneWidget);
    });
  });

  group('import', () {
    testWidgets('picks a .skvault, previews the selection and imports it',
        (tester) async {
      fakeExport.decryptResult = DecryptedBackup(
        credentials: [
          _c('a'),
          _c('b', type: CredentialType.totp),
        ],
        folders: const [],
      );
      FilePicker.platform = FakeFilePicker(
          pickResult: pickedFile('backup.skvault', Uint8List(16)));

      await pumpTransfer(tester, creds: [_c('1')]);

      // Move to the Import tab and start the flow.
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select file (.skvault)'));
      await tester.pumpAndSettle();

      // The selection sheet previews the decrypted backup.
      expect(find.text('Select what to import'), findsOneWidget);
      expect(find.text('Authenticators (TOTP)'), findsOneWidget);

      await tester.tap(find.text('Import selection'));
      await tester.pumpAndSettle();

      expect(fakeExport.importCalls, 1);
      expect(fakeExport.lastImportMode, ImportMode.merge);
      expect(find.text('Import completed'), findsOneWidget);
    });

    testWidgets('a cancelled file picker imports nothing', (tester) async {
      FilePicker.platform = FakeFilePicker(pickResult: null); // user cancelled

      await pumpTransfer(tester, creds: [_c('1')]);

      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select file (.skvault)'));
      await tester.pumpAndSettle();

      expect(fakeExport.importCalls, 0);
      expect(find.text('Select what to import'), findsNothing);
    });
  });
}
