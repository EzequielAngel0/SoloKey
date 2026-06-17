import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/vault_export_service.dart';
import '../../../core/services/csv_import_service.dart';
import '../../../features/credentials/application/credentials_provider.dart';
import '../../../features/credentials/domain/entities/credential.dart';
import '../../../features/folders/application/folders_provider.dart';
import '../../../shared/widgets/vault_app_bar.dart';

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

  String _typeLabel(CredentialType type) => switch (type) {
        CredentialType.password => 'Contraseñas',
        CredentialType.apiKey => 'API Keys',
        CredentialType.secureNote => 'Notas seguras',
        CredentialType.totp => 'Autenticadores (TOTP)',
        CredentialType.passkey => 'Passkeys',
      };

  IconData _typeIcon(CredentialType type) => switch (type) {
        CredentialType.password => Icons.lock_rounded,
        CredentialType.apiKey => Icons.vpn_key_rounded,
        CredentialType.secureNote => Icons.note_rounded,
        CredentialType.totp => Icons.qr_code_rounded,
        CredentialType.passkey => Icons.fingerprint_rounded,
      };

  Future<void> _doExport() async {
    final password = _exportPasswordCtrl.text.trim();
    if (password.isEmpty) {
      _snack('Ingresa una contraseña de exportación', error: true);
      return;
    }
    if (_selectedTypes.isEmpty) {
      _snack('Selecciona al menos un tipo de credencial', error: true);
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
          'Exportadas ${summary.totalCredentials} credenciales · '
          '${summary.totalFolders} carpetas',
        );
      }
    } catch (e) {
      if (mounted) _snack('Error al exportar: $e', error: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _doImport() async {
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
      if (mounted) _snack('Error al importar: $e', error: true);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _doImportCsv() async {
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
      if (mounted) _snack('Error al importar CSV: $e', error: true);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<bool> _confirmReplace() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text(
              '¿Sobrescribir bóveda?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Esta acción eliminará TODAS las credenciales actuales y las '
              'reemplazará con las del archivo. Esta operación no se puede deshacer.',
              style: TextStyle(color: Color(0xFF9E9EBF)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Sobrescribir',
                  style: TextStyle(color: Color(0xFFCF6679)),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            error ? const Color(0xFFCF6679) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VaultAppBar(
        title: 'Transferir datos',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF5C5C7A),
          tabs: const [
            Tab(icon: Icon(Icons.upload_rounded), text: 'Exportar'),
            Tab(icon: Icon(Icons.download_rounded), text: 'Importar'),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Export password ──────────────────────────────────────────────────
        _SectionLabel(label: 'Contraseña de exportación'),
        const SizedBox(height: 8),
        _InfoBanner(
          icon: Icons.info_outline_rounded,
          color: const Color(0xFF6C63FF),
          text: 'Crea una contraseña para proteger este backup. '
              'Necesitarás ingresarla al importar en cualquier dispositivo.',
        ),
        const SizedBox(height: 12),
        _PasswordField(
          controller: passwordCtrl,
          label: 'Contraseña de exportación',
          hint: 'Ej: "mi-clave-backup-2025"',
        ),

        const SizedBox(height: 24),

        // ── Type filter ──────────────────────────────────────────────────────
        _SectionLabel(label: 'Selecciona qué exportar'),
        const SizedBox(height: 8),
        _Card(
          children: CredentialType.values
              .map(
                (t) => CheckboxListTile(
                  value: selectedTypes.contains(t),
                  onChanged: (v) => onTypeToggled(t, v ?? false),
                  title: Text(
                    typeLabel(t),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  secondary: Icon(typeIcon(t), color: const Color(0xFF6C63FF)),
                  activeColor: const Color(0xFF6C63FF),
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 20),
        _InfoBanner(
          icon: Icons.lock_rounded,
          color: const Color(0xFF4CAF50),
          text: 'El archivo se cifra con AES-256-GCM + Argon2id. '
              'Solo quién conozca la contraseña de exportación puede abrirlo.',
        ),
        const SizedBox(height: 24),

        if (isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          )
        else
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Exportar bóveda'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),

        if (lastSummary != null) ...[
          const SizedBox(height: 16),
          _ResultCard(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF4CAF50),
            title: 'Exportación completada',
            subtitle: '${lastSummary!.totalCredentials} credenciales · '
                '${lastSummary!.totalFolders} carpetas',
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Export password ──────────────────────────────────────────────────
        _SectionLabel(label: 'Contraseña del backup'),
        const SizedBox(height: 8),
        _InfoBanner(
          icon: Icons.key_rounded,
          color: const Color(0xFF6C63FF),
          text: 'Ingresa la contraseña que usaste al exportar el backup. '
              'Si importas un backup tuyo del mismo dispositivo puedes '
              'dejar este campo vacío.',
        ),
        const SizedBox(height: 12),
        _PasswordField(
          controller: passwordCtrl,
          label: 'Contraseña de exportación',
          hint: 'Déjala vacía para backups del mismo dispositivo',
        ),

        const SizedBox(height: 24),

        // ── Mode ─────────────────────────────────────────────────────────────
        _SectionLabel(label: 'Modo de importación'),
        const SizedBox(height: 8),
        _Card(
          children: [
            _RadioTile<ImportMode>(
              value: ImportMode.merge,
              groupValue: mode,
              onChanged: onModeChanged,
              activeColor: const Color(0xFF6C63FF),
              title: const Text(
                'Combinar',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              subtitle: const Text(
                'Añadir sin borrar tus credenciales actuales',
                style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 12),
              ),
            ),
            const Divider(height: 1, indent: 48, color: Color(0xFF2A2A4A)),
            _RadioTile<ImportMode>(
              value: ImportMode.replace,
              groupValue: mode,
              onChanged: onModeChanged,
              activeColor: const Color(0xFFCF6679),
              title: const Text(
                'Sobrescribir',
                style: TextStyle(color: Color(0xFFCF6679), fontSize: 14),
              ),
              subtitle: const Text(
                'Borrará todo y reemplazará con el archivo',
                style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 12),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          )
        else ...[
          ElevatedButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Seleccionar archivo (.skvault)'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onImportCsv,
            icon: const Icon(Icons.description_rounded, color: Color(0xFF03DAC6)),
            label: const Text('Importar desde CSV (Bitwarden/Chrome/1Pass)', style: TextStyle(color: Color(0xFF03DAC6))),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Color(0xFF03DAC6)),
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
                ? const Color(0xFF4CAF50)
                : const Color(0xFFCF6679),
            title:
                lastResult!.success ? 'Importación completada' : 'Error',
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
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Color(0xFF5C5C7A), fontSize: 12),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: const Color(0xFF9E9EBF),
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
                      _selected ? activeColor : const Color(0xFF5C5C7A),
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
                  if (subtitle != null) subtitle,
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
      style: const TextStyle(
        color: Color(0xFF9E9EBF),
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
        color: const Color(0xFF16213E),
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
    this.color = const Color(0xFF6C63FF),
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
              style: const TextStyle(
                color: Color(0xFF9E9EBF),
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
                  style: const TextStyle(
                    color: Color(0xFF9E9EBF),
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
