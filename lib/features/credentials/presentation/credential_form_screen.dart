import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/extensions/color_extensions.dart';
import '../../../shared/widgets/secure_text_field.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_colors.dart';
import '../application/credentials_provider.dart';
import '../../folders/application/folders_provider.dart';
import '../domain/entities/credential.dart';
import '../../folders/domain/entities/folder.dart';
import 'qr_scanner_screen.dart';
import 'widgets/password_generator_widget.dart';

class CredentialFormScreen extends ConsumerStatefulWidget {
  const CredentialFormScreen({super.key, this.existingId});
  final String? existingId;

  @override
  ConsumerState<CredentialFormScreen> createState() =>
      _CredentialFormScreenState();
}

class _CredentialFormScreenState extends ConsumerState<CredentialFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Shared controllers
  final _titleCtrl    = TextEditingController();
  final _notesCtrl    = TextEditingController();

  // Password / Login
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _websiteCtrl  = TextEditingController();

  // API Key
  final _serviceCtrl  = TextEditingController();
  final _apiKeyCtrl   = TextEditingController();
  final _endpointCtrl = TextEditingController();
  final _scopesCtrl   = TextEditingController();

  // TOTP
  final _totpSecretCtrl = TextEditingController();
  final _totpIssuerCtrl = TextEditingController();

  CredentialType _type = CredentialType.password;
  String? _folderId;
  bool _isFavorite = false;
  bool _isLoading  = false;
  bool _showGenerator = false;
  Credential? _existing;

  late AnimationController _saveAnimCtrl;
  late Animation<double> _saveScale;

  @override
  void initState() {
    super.initState();
    _saveAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _saveScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _saveAnimCtrl, curve: Curves.easeInOut),
    );
    if (widget.existingId != null) _loadExisting();
  }

  void _loadExisting() {
    final creds = ref.read(credentialsNotifierProvider).valueOrNull;
    _existing = creds?.where((c) => c.id == widget.existingId).firstOrNull;
    if (_existing != null) {
      _titleCtrl.text = _existing!.title;
      _notesCtrl.text = _existing!.notes ?? '';
      _type = _existing!.type;
      _isFavorite = _existing!.isFavorite;
      _folderId = _existing!.categoryId;

      // Populate type-specific fields from customFields map
      final cf = {for (final f in _existing!.customFields) f.label: f.value};
      _usernameCtrl.text = _existing!.username ?? '';
      _passwordCtrl.text = _existing!.password ?? '';
      _websiteCtrl.text  = _existing!.website ?? '';
      _serviceCtrl.text  = cf['service'] ?? '';
      _apiKeyCtrl.text   = _existing!.password ?? '';
      _endpointCtrl.text = cf['endpoint'] ?? '';
      _scopesCtrl.text   = cf['scopes'] ?? '';
      _totpSecretCtrl.text = _existing!.password ?? '';
      _totpIssuerCtrl.text = cf['issuer'] ?? '';
    }
  }

  @override
  void dispose() {
    _saveAnimCtrl.dispose();
    for (final c in [
      _titleCtrl, _notesCtrl, _usernameCtrl, _passwordCtrl, _websiteCtrl,
      _serviceCtrl, _apiKeyCtrl, _endpointCtrl, _scopesCtrl,
      _totpSecretCtrl, _totpIssuerCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Credential _buildCredential() {
    final now = DateTime.now();
    switch (_type) {
      case CredentialType.password:
        return Credential(
          id: _existing?.id ?? const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          username: _usernameCtrl.text.trim().isEmpty ? null : _usernameCtrl.text.trim(),
          password: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
          website:  _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          isFavorite: _isFavorite,
          categoryId: _folderId,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
        );

      case CredentialType.apiKey:
        return Credential(
          id: _existing?.id ?? const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          username: _serviceCtrl.text.trim().isEmpty ? null : _serviceCtrl.text.trim(),
          password: _apiKeyCtrl.text.isEmpty ? null : _apiKeyCtrl.text,
          website: _endpointCtrl.text.trim().isEmpty ? null : _endpointCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          customFields: _scopesCtrl.text.trim().isEmpty
              ? []
              : [CustomField(label: 'scopes', value: _scopesCtrl.text.trim())],
          isFavorite: _isFavorite,
          categoryId: _folderId,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
        );

      case CredentialType.secureNote:
        return Credential(
          id: _existing?.id ?? const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          isFavorite: _isFavorite,
          categoryId: _folderId,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
        );

      case CredentialType.totp:
        return Credential(
          id: _existing?.id ?? const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          password: _totpSecretCtrl.text.isEmpty ? null : _totpSecretCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          customFields: _totpIssuerCtrl.text.trim().isEmpty
              ? []
              : [CustomField(label: 'issuer', value: _totpIssuerCtrl.text.trim())],
          isFavorite: _isFavorite,
          categoryId: _folderId,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
        );

      // Passkeys are registered via the platform FIDO2 API, not via this form.
      // Existing passkey credentials are read-only here.
      case CredentialType.passkey:
        return _existing!.copyWith(updatedAt: now);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _saveAnimCtrl.forward();
    await _saveAnimCtrl.reverse();
    setState(() => _isLoading = true);

    final credential = _buildCredential();
    try {
      if (_existing == null) {
        await ref.read(credentialsNotifierProvider.notifier).save(credential);
      } else {
        await ref.read(credentialsNotifierProvider.notifier).updateCredential(credential);
      }
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _existing == null ? 'Credencial creada' : 'Cambios guardados',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanQr() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code == null) return;
    
    try {
      final uri = Uri.parse(code);
      if (uri.scheme.toLowerCase() != 'otpauth') {
        _showError('El código QR no es un TOTP válido.');
        return;
      }
      
      String? titleFromPath;
      if (uri.pathSegments.isNotEmpty) {
        titleFromPath = uri.pathSegments.first;
        if (titleFromPath.contains(':')) {
          titleFromPath = titleFromPath.split(':').last;
        }
      }

      final secret = uri.queryParameters['secret'];
      final issuer = uri.queryParameters['issuer'] ??
          (uri.pathSegments.isNotEmpty && uri.pathSegments.first.contains(':')
              ? Uri.decodeComponent(uri.pathSegments.first.split(':').first)
              : null);

      if (secret != null && secret.isNotEmpty) {
        setState(() {
          _totpSecretCtrl.text = secret;
          if (issuer != null && _totpIssuerCtrl.text.isEmpty) {
            _totpIssuerCtrl.text = issuer;
          }
          if (titleFromPath != null && _titleCtrl.text.isEmpty) {
            _titleCtrl.text = Uri.decodeComponent(titleFromPath);
          }
        });
        HapticFeedback.mediumImpact();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.qr_code_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Código QR escaneado con éxito'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        _showError('No se encontró una clave secreta en el QR.');
      }
    } catch (e) {
      _showError('Error al leer el código QR.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing != null;
    final typeColor = _typeColor(_type);

    return Scaffold(
      appBar: VaultAppBar(
        title: isEdit ? 'Editar credencial' : 'Nueva credencial',
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                isEdit ? 'Guardar' : 'Crear',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // ── Type selector (premium horizontal scroll) ──────────────
            _TypeSelectorPremium(
              selected: _type,
              isEditing: isEdit,
              onChanged: (t) => setState(() {
                _type = t;
                _showGenerator = false;
              }),
            ),
            const SizedBox(height: 24),

            // ── Header section: Title + Favorite ──────────────────────
            _FormSection(
              icon: Icons.badge_rounded,
              accentColor: typeColor,
              title: 'Identificación',
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Título',
                    hintText: _titleHint,
                    prefixIcon: Icon(_typeIcon(_type), size: 18, color: typeColor.withValues(alpha: 0.7)),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                _FavoriteToggle(
                  value: _isFavorite,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _isFavorite = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Type-specific fields ───────────────────────────────────
            _buildFieldsByType(),

            // ── Notes (common except TOTP) ─────────────────────────────
            if (_type != CredentialType.totp) ...[
              const SizedBox(height: 16),
              _FormSection(
                icon: Icons.notes_rounded,
                accentColor: typeColor,
                title: _type == CredentialType.secureNote ? 'Contenido' : 'Notas',
                children: [
                  TextFormField(
                    controller: _notesCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: _type == CredentialType.secureNote ? 10 : 4,
                    decoration: InputDecoration(
                      labelText: _type == CredentialType.secureNote
                          ? 'Contenido seguro'
                          : 'Notas adicionales',
                      hintText: _type == CredentialType.secureNote
                          ? 'Escribe tu nota privada aquí…'
                          : 'Opcional — agregar contexto o recordatorios',
                      alignLabelWithHint: true,
                    ),
                    validator: _type == CredentialType.secureNote
                        ? (v) => v == null || v.trim().isEmpty
                            ? 'El contenido es requerido'
                            : null
                        : null,
                  ),
                ],
              ),
            ],

            // ── Folder Picker ───────────────────────────────────────────
            const SizedBox(height: 16),
            _FormSection(
              icon: Icons.folder_rounded,
              accentColor: AppColors.textMuted,
              title: 'Organización',
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final folders = ref.watch(foldersNotifierProvider).valueOrNull ?? [];
                    final currentFolder = folders.where((f) => f.id == _folderId).firstOrNull;
                    
                    return InkWell(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        final List<String?>? selection = await showModalBottomSheet<List<String?>>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.drawer,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (_) => _FolderPickerSheet(selectedFolderId: _folderId),
                        );
                        if (selection != null) {
                          setState(() => _folderId = selection.first);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Carpeta',
                          prefixIcon: Icon(Icons.folder_outlined, color: AppColors.textMuted),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                currentFolder?.name ?? 'Bóveda principal',
                                style: TextStyle(
                                  color: currentFolder == null ? AppColors.textMuted : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Save button ─────────────────────────────────────────────
            ScaleTransition(
              scale: _saveScale,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : _SaveButton(
                      label: isEdit ? 'Guardar cambios' : 'Crear credencial',
                      color: typeColor,
                      onPressed: _save,
                      icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String get _titleHint => switch (_type) {
    CredentialType.password   => 'ej. Netflix, GitHub, Gmail',
    CredentialType.apiKey     => 'ej. OpenAI, Stripe, AWS',
    CredentialType.secureNote => 'ej. Llaves del servidor, Seeds',
    CredentialType.totp       => 'ej. GitHub 2FA, Google',
    CredentialType.passkey    => 'ej. google.com Passkey',
  };

  IconData _typeIcon(CredentialType t) => switch (t) {
    CredentialType.password   => Icons.lock_rounded,
    CredentialType.apiKey     => Icons.key_rounded,
    CredentialType.secureNote => Icons.note_rounded,
    CredentialType.totp       => Icons.access_time_rounded,
    CredentialType.passkey    => Icons.fingerprint_rounded,
  };

  Color _typeColor(CredentialType t) => switch (t) {
    CredentialType.password   => AppColors.typePassword,
    CredentialType.apiKey     => AppColors.typeApiKey,
    CredentialType.secureNote => AppColors.typeNote,
    CredentialType.totp       => AppColors.typeTotp,
    CredentialType.passkey    => AppColors.typePasskey,
  };

  Widget _buildFieldsByType() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(_type),
        child: switch (_type) {
          CredentialType.password => _buildPasswordFields(),
          CredentialType.apiKey   => _buildApiKeyFields(),
          CredentialType.secureNote => const SizedBox.shrink(),
          CredentialType.totp     => _buildTotpFields(),
          CredentialType.passkey  => _buildPasskeyInfo(),
        },
      ),
    );
  }

  Widget _buildPasswordFields() {
    return _FormSection(
      icon: Icons.lock_rounded,
      accentColor: AppColors.typePassword,
      title: 'Credenciales de acceso',
      children: [
        TextFormField(
          controller: _usernameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Usuario / Email',
            hintText: 'usuario@ejemplo.com',
            prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textMuted),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _PasswordRow(
          ctrl: _passwordCtrl,
          label: 'Contraseña',
          showGenerator: _showGenerator,
          onToggleGenerator: (v) => setState(() => _showGenerator = v),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _websiteCtrl,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Sitio web / URL',
            hintText: 'https://ejemplo.com',
            prefixIcon: Icon(Icons.language_rounded, size: 18, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyFields() {
    return _FormSection(
      icon: Icons.key_rounded,
      accentColor: AppColors.typeApiKey,
      title: 'Detalles de la API',
      children: [
        TextFormField(
          controller: _serviceCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre del servicio',
            hintText: 'ej. OpenAI, Stripe, Supabase',
            prefixIcon: Icon(Icons.cloud_rounded, size: 18, color: AppColors.textMuted),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 14),
        _PasswordRow(
          ctrl: _apiKeyCtrl,
          label: 'API Key / Token',
          showGenerator: _showGenerator,
          onToggleGenerator: (v) => setState(() => _showGenerator = v),
          validator: (v) =>
              v == null || v.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _endpointCtrl,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Endpoint URL',
            hintText: 'https://api.example.com/v1',
            prefixIcon: Icon(Icons.link_rounded, size: 18, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _scopesCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Permisos / Scopes',
            hintText: 'read:user, write:repo…',
            prefixIcon: Icon(Icons.security_rounded, size: 18, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildTotpFields() {
    return _FormSection(
      icon: Icons.access_time_rounded,
      accentColor: AppColors.typeTotp,
      title: 'Configuración 2FA',
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.typeTotp.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.typeTotp.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.typeTotp.withValues(alpha: 0.8)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ingresa la clave secreta TOTP (Base32) de tu cuenta. '
                  'La encontrarás al activar 2FA en el sitio web, '
                  'o puedes escanear el código QR directamente.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // QR scan button — prominent
        Material(
          color: AppColors.typeTotp.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _scanQr,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.typeTotp.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: AppColors.typeTotp, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Escanear código QR',
                    style: TextStyle(
                      color: AppColors.typeTotp,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        // Divider with "o"
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.divider.withValues(alpha: 0.5))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('o ingresa manualmente', style: TextStyle(color: AppColors.textDisabled, fontSize: 11)),
            ),
            Expanded(child: Divider(color: AppColors.divider.withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _totpIssuerCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Cuenta / Emisor',
            hintText: 'ej. GitHub, Google, AWS',
            prefixIcon: Icon(Icons.account_circle_outlined, size: 18, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),
        SecureTextField(
          controller: _totpSecretCtrl,
          label: 'Clave secreta TOTP (Base32)',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Campo requerido' : null,
        ),
      ],
    );
  }

  Widget _buildPasskeyInfo() {
    return _FormSection(
      icon: Icons.fingerprint_rounded,
      accentColor: AppColors.typePasskey,
      title: 'Passkey (FIDO2)',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.typePasskey.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.typePasskey.withValues(alpha: 0.2),
            ),
          ),
          child: const Column(
            children: [
              Icon(Icons.fingerprint_rounded, color: AppColors.typePasskey, size: 32),
              SizedBox(height: 12),
              Text(
                'Las Passkeys se registran directamente con la plataforma '
                'FIDO2 del dispositivo.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Usa la pantalla de Passkeys en Ajustes para registrar o gestionar tus passkeys.',
                style: TextStyle(color: AppColors.textDisabled, fontSize: 12, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Form Section wrapper — groups fields with visual identity ─────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ── Save button with gradient ────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.color,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Premium Type Selector ──────────────────────────────────────────────────────

class _TypeSelectorPremium extends StatelessWidget {
  const _TypeSelectorPremium({
    required this.selected,
    required this.onChanged,
    this.isEditing = false,
  });

  final CredentialType selected;
  final ValueChanged<CredentialType> onChanged;
  final bool isEditing;

  static const _items = [
    (type: CredentialType.password,   label: 'Contraseña', icon: Icons.lock_rounded,          color: AppColors.typePassword),
    (type: CredentialType.apiKey,     label: 'API Key',    icon: Icons.key_rounded,           color: AppColors.typeApiKey),
    (type: CredentialType.secureNote, label: 'Nota',       icon: Icons.note_rounded,          color: AppColors.typeNote),
    (type: CredentialType.totp,       label: 'TOTP',       icon: Icons.access_time_rounded,   color: AppColors.typeTotp),
    (type: CredentialType.passkey,    label: 'Passkey',    icon: Icons.fingerprint_rounded,   color: AppColors.typePasskey),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = _items[i];
          final isSelected = item.type == selected;
          final isDisabled = isEditing && item.type != selected;

          return GestureDetector(
            onTap: isDisabled ? null : () {
              HapticFeedback.selectionClick();
              onChanged(item.type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isSelected ? 100 : 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.color.withValues(alpha: 0.15)
                    : isDisabled
                        ? AppColors.card.withValues(alpha: 0.5)
                        : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? item.color : Colors.transparent,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: item.color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      item.icon,
                      color: isSelected ? item.color : isDisabled ? AppColors.textDisabled : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? item.color : isDisabled ? AppColors.textDisabled : AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Password row with embedded generator ─────────────────────────────────────

class _PasswordRow extends StatelessWidget {
  const _PasswordRow({
    required this.ctrl,
    required this.label,
    required this.showGenerator,
    required this.onToggleGenerator,
    this.validator,
  });

  final TextEditingController ctrl;
  final String label;
  final bool showGenerator;
  final ValueChanged<bool> onToggleGenerator;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SecureTextField(
                controller: ctrl,
                label: label,
                validator: validator,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: showGenerator
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showGenerator
                      ? AppColors.accent.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.auto_fix_high_rounded,
                  color: showGenerator
                      ? AppColors.accent
                      : AppColors.textMuted,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  FocusScope.of(context).unfocus();
                  onToggleGenerator(!showGenerator);
                },
                tooltip: 'Generador de claves',
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          alignment: Alignment.topCenter,
          child: showGenerator
              ? PasswordGeneratorWidget(
                  onApplyPassword: (pass) {
                    ctrl.text = pass;
                    HapticFeedback.mediumImpact();
                    onToggleGenerator(false);
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Favorite toggle ───────────────────────────────────────────────────────────

class _FavoriteToggle extends StatelessWidget {
  const _FavoriteToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedScale(
              scale: value ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                value ? Icons.star_rounded : Icons.star_border_rounded,
                color: value ? AppColors.warning : AppColors.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Marcar como favorita',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            const Spacer(),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Folder picker bottom sheet ────────────────────────────────────────────────

class _FolderPickerSheet extends ConsumerWidget {
  const _FolderPickerSheet({this.selectedFolderId});
  final String? selectedFolderId;

  Future<void> _createNewFolder(BuildContext context, WidgetRef ref, String? parentId) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.drawer,
        title: const Text('Nueva carpeta', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Nombre de la carpeta'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Crear')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final newFolder = await ref.read(foldersNotifierProvider.notifier).createFolder(name: name, parentId: parentId);
      if (context.mounted) Navigator.pop(context, <String?>[newFolder.id]);
    }
  }

  Widget _buildNode(BuildContext context, WidgetRef ref, List<Folder> all, Folder f, int depth) {
    final sub = all.where((sub) => sub.parentId == f.id).toList();
    final isSelected = selectedFolderId == f.id;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(left: 16 + depth * 16.0, right: 16),
        title: GestureDetector(
          onTap: () => Navigator.pop(context, <String?>[f.id]),
          child: Row(
            children: [
              Icon(f.isFavorite ? Icons.folder_special_rounded : Icons.folder_rounded, color: f.colorHex.toColor()),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  f.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.accent : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 16),
              ]
            ],
          ),
        ),
        childrenPadding: EdgeInsets.zero,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined, color: AppColors.textMuted),
              onPressed: () => _createNewFolder(context, ref, f.id),
              tooltip: 'Añadir subcarpeta',
            ),
            if (sub.isNotEmpty)
              const Icon(Icons.expand_more, color: AppColors.textDisabled)
            else
              const SizedBox(width: 24),
          ],
        ),
        children: sub.map((sf) => _buildNode(context, ref, all, sf, depth + 1)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersNotifierProvider).valueOrNull ?? [];
    final roots = folders.where((f) => f.parentId == null).toList();

    return Container(
      padding: const EdgeInsets.only(top: 16),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Seleccionar Carpeta', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _createNewFolder(context, ref, null),
                  icon: const Icon(Icons.create_new_folder_rounded, color: AppColors.accent),
                  label: const Text('Nueva raíz', style: TextStyle(color: AppColors.accent)),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: AppColors.textMuted),
                  title: Text(
                    'Ninguna (Bóveda principal)',
                    style: TextStyle(
                      color: selectedFolderId == null ? AppColors.accent : Colors.white,
                      fontWeight: selectedFolderId == null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: selectedFolderId == null ? const Icon(Icons.check_circle_rounded, color: AppColors.accent) : null,
                  onTap: () => Navigator.pop(context, <String?>[null]),
                ),
                ...roots.map((r) => _buildNode(context, ref, folders, r, 0)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
