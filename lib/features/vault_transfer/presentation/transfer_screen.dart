import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/vault_export_service.dart';
import '../../../core/services/csv_import_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/credentials/application/credentials_provider.dart';
import '../../../features/credentials/domain/entities/credential.dart';
import '../../../features/folders/application/folders_provider.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';

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
  final Set<CredentialType> _selectedTypes = {
    CredentialType.password,
    CredentialType.apiKey,
    CredentialType.secureNote,
    CredentialType.totp,
    CredentialType.sshKey,
  };
  final _exportPasswordCtrl = TextEditingController();
  bool _exporting = false;
  ExportSummary? _lastExport;

  // Import state
  ImportMode _importMode = ImportMode.merge;
  final _importPasswordCtrl = TextEditingController();
  bool _importing = false;
  ImportResult? _lastImport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _exportPasswordCtrl.dispose();
    _importPasswordCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _typeLabel(CredentialType type) {
    final l10n = AppLocalizations.of(context);
    return switch (type) {
      CredentialType.password => l10n.transferTypePasswords,
      CredentialType.apiKey => l10n.transferTypeApiKeys,
      CredentialType.secureNote => l10n.transferTypeSecureNotes,
      CredentialType.totp => l10n.transferTypeTotp,
      CredentialType.passkey => l10n.transferTypePasskeys,
      CredentialType.sshKey => l10n.transferTypeSshKeys,
    };
  }

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
    if (_selectedTypes.isEmpty) {
      _snack(l10n.transferSelectAtLeastOneType, error: true);
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
        typeFilter: _selectedTypes.length == CredentialType.values.length
            ? null
            : _selectedTypes,
      );
      if (mounted) {
        setState(() => _lastExport = summary);
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
    if (_importMode == ImportMode.replace) {
      final confirmed = await _confirmReplace();
      if (!confirmed) return;
    }
    setState(() {
      _importing = true;
      _lastImport = null;
    });
    try {
      final service = getIt<VaultExportService>();
      final result = await service.importVault(
        exportPassword: password,
        mode: _importMode,
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

  Future<void> _doImportCsv() async {
    final l10n = AppLocalizations.of(context);
    if (_importMode == ImportMode.replace) {
      final confirmed = await _confirmReplace();
      if (!confirmed) return;
    }
    setState(() {
      _importing = true;
      _lastImport = null;
    });
    try {
      final exportService = getIt<VaultExportService>();
      final csvService = getIt<CsvImportService>();
      final result = await exportService.importCsv(
        csvService: csvService,
        mode: _importMode,
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
      if (mounted) _snack(l10n.transferImportCsvError('$e'), error: true);
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
            selectedTypes: _selectedTypes,
            onTypeToggled: (type, val) => setState(() {
              if (val) {
                _selectedTypes.add(type);
              } else {
                _selectedTypes.remove(type);
              }
            }),
            passwordCtrl: _exportPasswordCtrl,
            onExport: _exporting ? null : _doExport,
            isLoading: _exporting,
            lastSummary: _lastExport,
            typeLabel: _typeLabel,
            typeIcon: _typeIcon,
          ),
          _ImportTab(
            mode: _importMode,
            onModeChanged: (m) => setState(() => _importMode = m),
            passwordCtrl: _importPasswordCtrl,
            onImport: _importing ? null : _doImport,
            onImportCsv: _importing ? null : _doImportCsv,
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
    required this.selectedTypes,
    required this.onTypeToggled,
    required this.passwordCtrl,
    required this.onExport,
    required this.isLoading,
    required this.lastSummary,
    required this.typeLabel,
    required this.typeIcon,
  });

  final Set<CredentialType> selectedTypes;
  final void Function(CredentialType, bool) onTypeToggled;
  final TextEditingController passwordCtrl;
  final VoidCallback? onExport;
  final bool isLoading;
  final ExportSummary? lastSummary;
  final String Function(CredentialType) typeLabel;
  final IconData Function(CredentialType) typeIcon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
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

        // ── Type filter ──────────────────────────────────────────────────────
        _SectionLabel(label: l10n.transferSelectWhatToExport),
        const SizedBox(height: 8),
        _Card(
          children: CredentialType.values
              .map(
                (t) => CheckboxListTile(
                  value: selectedTypes.contains(t),
                  onChanged: (v) => onTypeToggled(t, v ?? false),
                  title: Text(
                    typeLabel(t),
                    style: TextStyle(color: palette.textPrimary, fontSize: 14),
                  ),
                  secondary: Icon(typeIcon(t), color: palette.accent),
                  activeColor: palette.accent,
                  checkColor: palette.onPrimary,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              )
              .toList(),
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
    required this.isLoading,
    required this.lastResult,
  });

  final ImportMode mode;
  final ValueChanged<ImportMode> onModeChanged;
  final TextEditingController passwordCtrl;
  final VoidCallback? onImport;
  final VoidCallback? onImportCsv;
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
          label: l10n.transferExportPasswordLabel,
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
