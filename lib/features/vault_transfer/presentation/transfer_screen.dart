import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/vault_export_service.dart';
import '../../../core/services/csv_import_service.dart';
import '../../../core/services/otpauth_import_service.dart';
import '../../../core/services/backup_reminder_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/credentials/application/credentials_provider.dart';
import '../../../features/credentials/domain/entities/credential.dart';
import '../../../features/folders/application/folders_provider.dart';
import '../../../features/folders/domain/entities/folder.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';
import 'widgets/export_tree.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Export state
  final _exportPasswordCtrl = TextEditingController();
  bool _exporting = false;
  ExportSummary? _lastExport;

  /// Whether it's been a while since the last backup (nudges the user to export).
  /// Null when DI isn't configured (e.g. widget tests) — the reminder is skipped.
  BackupReminderService? _reminder;
  bool _backupStale = false;

  /// Ids of the credentials the user picked in the export tree. Empty = nothing
  /// selected yet (the tree starts collapsed; "Seleccionar todo" picks all).
  final Set<String> _selectedCredentialIds = {};

  // Import state
  ImportMode _importMode = ImportMode.merge;
  final _importPasswordCtrl = TextEditingController();
  bool _importing = false;
  ImportResult? _lastImport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    try {
      _reminder = BackupReminderService(getIt<FlutterSecureStorage>());
    } catch (_) {
      _reminder = null; // DI not configured (widget tests)
    }
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final reminder = _reminder;
    if (reminder == null) return;
    final stale = await reminder.isBackupStale();
    if (mounted) setState(() => _backupStale = stale);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _exportPasswordCtrl.dispose();
    _importPasswordCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  IconData _typeIcon(CredentialType type) => switch (type) {
        CredentialType.password => Icons.lock_rounded,
        CredentialType.apiKey => Icons.vpn_key_rounded,
        CredentialType.secureNote => Icons.note_rounded,
        CredentialType.totp => Icons.qr_code_rounded,
        CredentialType.passkey => Icons.fingerprint_rounded,
        CredentialType.sshKey => Icons.terminal_rounded,
      };

  Future<void> _doExport() async {
    final l10n = AppLocalizations.of(context);
    final password = _exportPasswordCtrl.text.trim();
    if (password.isEmpty) {
      _snack(l10n.transferExportPasswordRequired, error: true);
      return;
    }
    if (_selectedCredentialIds.isEmpty) {
      _snack(l10n.transferSelectAtLeastOneCredential, error: true);
      return;
    }
    setState(() {
      _exporting = true;
      _lastExport = null;
    });
    try {
      final service = getIt<VaultExportService>();
      final summary = await service.exportVault(
        exportPassword: password,
        credentialIds: {..._selectedCredentialIds},
      );
      if (mounted && summary != null) {
        await _reminder?.markExportedNow();
        setState(() {
          _lastExport = summary;
          _backupStale = false;
        });
        _snack(
          l10n.transferExportedSummary(
              summary.totalCredentials, summary.totalFolders),
        );
      }
    } catch (e) {
      if (mounted) _snack(l10n.transferExportError('$e'), error: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _doImport() async {
    final l10n = AppLocalizations.of(context);
    final password = _importPasswordCtrl.text.trim();

    setState(() {
      _importing = true;
      _lastImport = null;
    });
    DecryptedBackup? backup;
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final bytes = picked.files.first.bytes;
      if (bytes == null) {
        _snack(l10n.transferErrorTitle, error: true);
        return;
      }
      // Decrypt only — nothing is persisted until the user confirms the
      // selection in the sheet below.
      backup = await getIt<VaultExportService>().decryptBackup(
        fileBytes: bytes,
        exportPassword: password,
      );
    } catch (e) {
      if (mounted) _snack(l10n.transferImportError('$e'), error: true);
      return;
    } finally {
      if (mounted) setState(() => _importing = false);
    }

    if (mounted) await _runSelectiveImport(backup);
  }

  Future<void> _doImportCsv() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _importing = true;
      _lastImport = null;
    });
    DecryptedBackup? backup;
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final bytes = picked.files.first.bytes;
      if (bytes == null) {
        _snack(l10n.transferErrorTitle, error: true);
        return;
      }
      final csv = utf8.decode(bytes);
      backup = getIt<VaultExportService>()
          .parseCsvBackup(csv, getIt<CsvImportService>());
    } catch (e) {
      if (mounted) _snack(l10n.transferImportCsvError('$e'), error: true);
      return;
    } finally {
      if (mounted) setState(() => _importing = false);
    }

    if (mounted) await _runSelectiveImport(backup);
  }

  /// Imports TOTP accounts from a file containing one or more `otpauth://` URIs
  /// (e.g. exported from another authenticator). No export password needed.
  Future<void> _doImportOtpauth() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _importing = true;
      _lastImport = null;
    });
    DecryptedBackup? backup;
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final bytes = picked.files.first.bytes;
      if (bytes == null) {
        _snack(l10n.transferErrorTitle, error: true);
        return;
      }
      final content = utf8.decode(bytes, allowMalformed: true);
      final service = OtpAuthImportService();
      final creds = service.parse(content);
      if (creds.isEmpty) {
        _snack(
          service.containsMigrationPayload(content)
              ? l10n.transferOtpauthMigrationUnsupported
              : l10n.transferOtpauthNone,
          error: true,
        );
        return;
      }
      backup = DecryptedBackup(credentials: creds, folders: const []);
    } catch (e) {
      if (mounted) _snack(l10n.transferImportError('$e'), error: true);
      return;
    } finally {
      if (mounted) setState(() => _importing = false);
    }

    if (mounted) await _runSelectiveImport(backup);
  }

  /// Shows the selection sheet for [backup], then performs a selective import
  /// of the chosen credential types and folders.
  Future<void> _runSelectiveImport(DecryptedBackup backup) async {
    final existing =
        ref.read(credentialsNotifierProvider).valueOrNull ?? const [];
    final selection = await showModalBottomSheet<_ImportSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ImportSelectionSheet(backup: backup, existing: existing),
    );
    if (selection == null || !mounted) return;

    final l10n = AppLocalizations.of(context);
    if (_importMode == ImportMode.replace) {
      final confirmed = await _confirmReplace();
      if (!confirmed || !mounted) return;
    }

    setState(() {
      _importing = true;
      _lastImport = null;
    });
    try {
      final result = await getIt<VaultExportService>().performSelectiveImport(
        backup: backup,
        mode: _importMode,
        typeFilter: selection.types,
        folderFilter: selection.folderKeys,
      );
      if (mounted) {
        setState(() => _lastImport = result);
        _snack(result.message, error: !result.success);

        // Refresh all screens so imported data appears immediately
        if (result.success) {
          ref.read(credentialsNotifierProvider.notifier).refresh();
          ref.read(foldersNotifierProvider.notifier).refresh();
        }
      }
    } catch (e) {
      if (mounted) _snack(l10n.transferImportError('$e'), error: true);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<bool> _confirmReplace() async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: palette.drawer,
            title: Text(
              l10n.transferOverwriteTitle,
              style: TextStyle(color: palette.textPrimary),
            ),
            content: Text(
              l10n.transferOverwriteBody,
              style: TextStyle(color: palette.textMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  l10n.transferOverwriteConfirm,
                  style: TextStyle(color: palette.danger),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    final palette = context.palette;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? palette.danger : palette.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final folders = ref.watch(foldersNotifierProvider).valueOrNull ?? [];
    final credentials =
        ref.watch(credentialsNotifierProvider).valueOrNull ?? [];
    return Scaffold(
      appBar: VaultAppBar(
        title: l10n.transferTitle,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: palette.accent,
          labelColor: palette.textPrimary,
          unselectedLabelColor: palette.textDisabled,
          tabs: [
            Tab(icon: const Icon(Icons.upload_rounded), text: l10n.transferTabExport),
            Tab(icon: const Icon(Icons.download_rounded), text: l10n.transferTabImport),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExportTab(
            folders: folders,
            credentials: credentials,
            selectedIds: _selectedCredentialIds,
            onSelectionChanged: (ids) => setState(() {
              _selectedCredentialIds
                ..clear()
                ..addAll(ids);
            }),
            typeIcon: _typeIcon,
            passwordCtrl: _exportPasswordCtrl,
            onExport: _exporting ? null : _doExport,
            isLoading: _exporting,
            lastSummary: _lastExport,
            backupStale: _backupStale,
          ),
          _ImportTab(
            mode: _importMode,
            onModeChanged: (m) => setState(() => _importMode = m),
            passwordCtrl: _importPasswordCtrl,
            onImport: _importing ? null : _doImport,
            onImportCsv: _importing ? null : _doImportCsv,
            onImportOtpauth: _importing ? null : _doImportOtpauth,
            isLoading: _importing,
            lastResult: _lastImport,
          ),
        ],
      ),
    );
  }
}

// ── Export tab ─────────────────────────────────────────────────────────────────

class _ExportTab extends StatelessWidget {
  const _ExportTab({
    required this.folders,
    required this.credentials,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.typeIcon,
    required this.passwordCtrl,
    required this.onExport,
    required this.isLoading,
    required this.lastSummary,
    required this.backupStale,
  });

  final List<Folder> folders;
  final List<Credential> credentials;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final IconData Function(CredentialType) typeIcon;
  final TextEditingController passwordCtrl;
  final VoidCallback? onExport;
  final bool isLoading;
  final ExportSummary? lastSummary;
  final bool backupStale;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (backupStale) ...[
          _InfoBanner(
            icon: Icons.history_toggle_off_rounded,
            color: palette.warning,
            text: l10n.transferBackupReminder,
          ),
          const SizedBox(height: 20),
        ],
        // ── Export password ──────────────────────────────────────────────────
        _SectionLabel(label: l10n.transferExportPasswordLabel),
        const SizedBox(height: 8),
        _InfoBanner(
          icon: Icons.info_outline_rounded,
          color: palette.accent,
          text: l10n.transferExportPasswordInfo,
        ),
        const SizedBox(height: 12),
        _PasswordField(
          controller: passwordCtrl,
          label: l10n.transferExportPasswordLabel,
          hint: l10n.transferExportPasswordHint,
        ),

        const SizedBox(height: 24),

        // ── What to export: folder/credential tree ───────────────────────────
        _SectionLabel(label: l10n.transferSelectCredentials),
        const SizedBox(height: 8),
        ExportTree(
          folders: folders,
          credentials: credentials,
          selectedIds: selectedIds,
          onSelectionChanged: onSelectionChanged,
          typeIcon: typeIcon,
        ),

        const SizedBox(height: 20),
        _InfoBanner(
          icon: Icons.lock_rounded,
          color: palette.success,
          text: l10n.transferEncryptionInfo,
        ),
        const SizedBox(height: 24),

        if (isLoading)
          Center(
            child: CircularProgressIndicator(color: palette.accent),
          )
        else
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.upload_rounded),
            label: Text(l10n.transferExportButton),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),

        if (lastSummary != null) ...[
          const SizedBox(height: 16),
          _ResultCard(
            icon: Icons.check_circle_rounded,
            color: palette.success,
            title: l10n.transferExportDone,
            subtitle: l10n.transferSummary(
                lastSummary!.totalCredentials, lastSummary!.totalFolders),
          ),
          if (lastSummary!.savedPath != null) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Icons.folder_open_rounded,
              color: palette.accent,
              text: l10n.transferSavedTo(lastSummary!.savedPath!),
            ),
          ],
        ],
      ],
    );
  }
}

// ── Import tab ─────────────────────────────────────────────────────────────────

class _ImportTab extends StatelessWidget {
  const _ImportTab({
    required this.mode,
    required this.onModeChanged,
    required this.passwordCtrl,
    required this.onImport,
    required this.onImportCsv,
    required this.onImportOtpauth,
    required this.isLoading,
    required this.lastResult,
  });

  final ImportMode mode;
  final ValueChanged<ImportMode> onModeChanged;
  final TextEditingController passwordCtrl;
  final VoidCallback? onImport;
  final VoidCallback? onImportCsv;
  final VoidCallback? onImportOtpauth;
  final bool isLoading;
  final ImportResult? lastResult;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Export password ──────────────────────────────────────────────────
        _SectionLabel(label: l10n.transferBackupPasswordLabel),
        const SizedBox(height: 8),
        _InfoBanner(
          icon: Icons.key_rounded,
          color: palette.accent,
          text: l10n.transferImportPasswordInfo,
        ),
        const SizedBox(height: 12),
        _PasswordField(
          controller: passwordCtrl,
          label: l10n.transferBackupPasswordLabel,
          hint: l10n.transferImportPasswordHint,
        ),

        const SizedBox(height: 24),

        // ── Mode ─────────────────────────────────────────────────────────────
        _SectionLabel(label: l10n.transferImportModeLabel),
        const SizedBox(height: 8),
        _Card(
          children: [
            _RadioTile<ImportMode>(
              value: ImportMode.merge,
              groupValue: mode,
              onChanged: onModeChanged,
              activeColor: palette.accent,
              title: Text(
                l10n.transferModeMerge,
                style: TextStyle(color: palette.textPrimary, fontSize: 14),
              ),
              subtitle: Text(
                l10n.transferModeMergeSub,
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
            ),
            Divider(height: 1, indent: 48, color: palette.divider),
            _RadioTile<ImportMode>(
              value: ImportMode.replace,
              groupValue: mode,
              onChanged: onModeChanged,
              activeColor: palette.danger,
              title: Text(
                l10n.transferModeOverwrite,
                style: TextStyle(color: palette.danger, fontSize: 14),
              ),
              subtitle: Text(
                l10n.transferModeOverwriteSub,
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        if (isLoading)
          Center(
            child: CircularProgressIndicator(color: palette.accent),
          )
        else ...[
          ElevatedButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.download_rounded),
            label: Text(l10n.transferSelectFile),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onImportCsv,
            icon: Icon(Icons.description_rounded, color: palette.secondary),
            label: Text(l10n.transferImportCsv, style: TextStyle(color: palette.secondary)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: palette.secondary),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onImportOtpauth,
            icon: Icon(Icons.qr_code_rounded, color: palette.typeTotp),
            label: Text(l10n.transferImportOtpauth,
                style: TextStyle(color: palette.typeTotp)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: palette.typeTotp),
            ),
          ),
        ],

        if (lastResult != null) ...[
          const SizedBox(height: 16),
          _ResultCard(
            icon: lastResult!.success
                ? Icons.check_circle_rounded
                : Icons.error_rounded,
            color: lastResult!.success
                ? palette.success
                : palette.danger,
            title:
                lastResult!.success ? l10n.transferImportDone : l10n.transferErrorTitle,
            subtitle: lastResult!.message,
          ),
        ],
      ],
    );
  }
}

// ── Shared utility widgets ─────────────────────────────────────────────────────

/// Password text field with show/hide toggle.
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    this.hint,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: TextStyle(color: palette.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: TextStyle(color: palette.textDisabled, fontSize: 12),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: palette.textMuted,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

/// Custom radio tile without deprecated Radio widget APIs.
class _RadioTile<T> extends StatelessWidget {
  const _RadioTile({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    required this.activeColor,
    this.subtitle,
  });

  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Widget title;
  final Widget? subtitle;
  final Color activeColor;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _selected ? activeColor : context.palette.textDisabled,
                  width: 2,
                ),
              ),
              child: _selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  ?subtitle,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: context.palette.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.color,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.palette.textMuted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Selective import sheet ──────────────────────────────────────────────────

/// User's choice in the import selection sheet.
class _ImportSelection {
  const _ImportSelection({required this.types, required this.folderKeys});

  /// Credential types to import.
  final Set<CredentialType> types;

  /// Folder keys to import (folder ids + [kNoFolderFilterId] for unfiled items).
  final Set<String> folderKeys;
}

/// Bottom sheet that previews a decrypted backup and lets the user pick which
/// credential types and folders to import before anything is persisted.
class _ImportSelectionSheet extends StatefulWidget {
  const _ImportSelectionSheet({required this.backup, required this.existing});

  final DecryptedBackup backup;

  /// Current vault credentials, used to preview how many of the selected items
  /// already exist (duplicates) before applying the import.
  final List<Credential> existing;

  @override
  State<_ImportSelectionSheet> createState() => _ImportSelectionSheetState();
}

class _ImportSelectionSheetState extends State<_ImportSelectionSheet> {
  final Map<CredentialType, int> _typeCounts = {};
  final Map<String, int> _folderCounts = {}; // key -> count
  final Map<String, String> _folderNames = {};
  final Set<CredentialType> _selectedTypes = {};
  final Set<String> _selectedFolderKeys = {};

  @override
  void initState() {
    super.initState();
    for (final c in widget.backup.credentials) {
      _typeCounts[c.type] = (_typeCounts[c.type] ?? 0) + 1;
      // La carpeta de la credencial se guarda en `categoryId` (no en `folderId`).
      final key = c.categoryId ?? kNoFolderFilterId;
      _folderCounts[key] = (_folderCounts[key] ?? 0) + 1;
    }
    for (final f in widget.backup.folders) {
      _folderNames[f.id] = f.name;
    }
    // Everything selected by default.
    _selectedTypes.addAll(_typeCounts.keys);
    _selectedFolderKeys.addAll(_folderCounts.keys);
  }

  bool get _canImport =>
      _selectedTypes.isNotEmpty && _selectedFolderKeys.isNotEmpty;

  String _typeLabel(CredentialType t, AppLocalizations l10n) => switch (t) {
        CredentialType.password => l10n.transferTypePasswords,
        CredentialType.apiKey => l10n.transferTypeApiKeys,
        CredentialType.secureNote => l10n.transferTypeSecureNotes,
        CredentialType.totp => l10n.transferTypeTotp,
        CredentialType.passkey => l10n.transferTypePasskeys,
        CredentialType.sshKey => l10n.transferTypeSshKeys,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final typeList = _typeCounts.keys.toList();

    // Duplicates among the CURRENT selection vs the existing vault.
    final selectedIncoming = widget.backup.credentials
        .where((c) =>
            _selectedTypes.contains(c.type) &&
            _selectedFolderKeys.contains(c.categoryId ?? kNoFolderFilterId))
        .toList();
    final duplicateCount =
        VaultExportService.countDuplicates(selectedIncoming, widget.existing);

    final folderList = _folderCounts.keys.toList()
      ..sort((a, b) {
        if (a == kNoFolderFilterId) return 1; // push "no folder" last
        if (b == kNoFolderFilterId) return -1;
        return (_folderNames[a] ?? a)
            .toLowerCase()
            .compareTo((_folderNames[b] ?? b).toLowerCase());
      });

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: palette.drawer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.download_rounded, color: palette.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.transferImportSelectTitle,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  _SectionLabel(label: l10n.transferSectionTypes),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      for (final t in typeList)
                        CheckboxListTile(
                          value: _selectedTypes.contains(t),
                          onChanged: (v) => setState(() {
                            if (v ?? false) {
                              _selectedTypes.add(t);
                            } else {
                              _selectedTypes.remove(t);
                            }
                          }),
                          activeColor: palette.accent,
                          checkColor: palette.onPrimary,
                          controlAffinity: ListTileControlAffinity.trailing,
                          secondary: _CountBadge(count: _typeCounts[t] ?? 0),
                          title: Text(
                            _typeLabel(t, l10n),
                            style: TextStyle(
                                color: palette.textPrimary, fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                  if (folderList.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionLabel(label: l10n.transferSectionFolders),
                    const SizedBox(height: 8),
                    _Card(
                      children: [
                        for (final key in folderList)
                          CheckboxListTile(
                            value: _selectedFolderKeys.contains(key),
                            onChanged: (v) => setState(() {
                              if (v ?? false) {
                                _selectedFolderKeys.add(key);
                              } else {
                                _selectedFolderKeys.remove(key);
                              }
                            }),
                            activeColor: palette.accent,
                            checkColor: palette.onPrimary,
                            controlAffinity: ListTileControlAffinity.trailing,
                            secondary: _CountBadge(count: _folderCounts[key] ?? 0),
                            title: Text(
                              key == kNoFolderFilterId
                                  ? l10n.transferNoFolder
                                  : (_folderNames[key] ?? key),
                              style: TextStyle(
                                  color: palette.textPrimary, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (duplicateCount > 0) ...[
                    const SizedBox(height: 20),
                    _InfoBanner(
                      icon: Icons.copy_all_rounded,
                      color: palette.warning,
                      text: l10n.transferDuplicatesWarning(duplicateCount),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _canImport
                        ? () => Navigator.pop(
                              context,
                              _ImportSelection(
                                types: _selectedTypes.toSet(),
                                folderKeys: _selectedFolderKeys.toSet(),
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.transferImportConfirm),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: palette.accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.palette.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
