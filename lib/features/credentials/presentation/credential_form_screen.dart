import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/widgets/secure_text_field.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_colors.dart';
import '../application/credentials_provider.dart';
import '../../folders/application/folders_provider.dart';
import '../domain/entities/credential.dart';
import 'qr_scanner_screen.dart';
import 'widgets/form_section.dart';
import 'widgets/save_button.dart';
import 'widgets/type_selector_premium.dart';
import 'widgets/password_row_widget.dart';
import 'widgets/favorite_toggle.dart';
import 'widgets/folder_picker_sheet.dart';
import '../../../app/di/injection.dart';
import '../../../core/infrastructure/security/double_envelope_service.dart';
import '../../../core/services/ssh_key_generator_service.dart';

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

  // SSH Key specific controllers
  final _sshPrivateKeyCtrl = TextEditingController();
  final _sshPublicKeyCtrl  = TextEditingController();
  final _sshPassphraseCtrl = TextEditingController();
  String _sshKeyType = 'Ed25519';

  // Double Envelope encryption state
  bool _isDoubleEncrypted = false;
  final _secondaryPinCtrl = TextEditingController();
  bool _savePinBiometrically = false;

  bool _isGeneratingSshKey = false;

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
      _isDoubleEncrypted = _existing!.isDoubleEncrypted;

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

      if (_type == CredentialType.sshKey && _existing!.sshKeyMetadata != null) {
        final ssh = _existing!.sshKeyMetadata!;
        _sshPrivateKeyCtrl.text = ssh.privateKey;
        _sshPublicKeyCtrl.text = ssh.publicKey;
        _sshPassphraseCtrl.text = ssh.passphrase ?? '';
        _sshKeyType = ssh.keyType;
      }

      // Check if biometric PIN was saved
      if (_isDoubleEncrypted) {
        getIt<DoubleEnvelopeService>().getPinFromSecureStorage(_existing!.id).then((savedPin) {
          if (mounted && savedPin != null) {
            setState(() {
              _savePinBiometrically = true;
              _secondaryPinCtrl.text = savedPin;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _saveAnimCtrl.dispose();
    for (final c in [
      _titleCtrl, _notesCtrl, _usernameCtrl, _passwordCtrl, _websiteCtrl,
      _serviceCtrl, _apiKeyCtrl, _endpointCtrl, _scopesCtrl,
      _totpSecretCtrl, _totpIssuerCtrl,
      _sshPrivateKeyCtrl, _sshPublicKeyCtrl, _sshPassphraseCtrl,
      _secondaryPinCtrl,
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

      case CredentialType.sshKey:
        return Credential(
          id: _existing?.id ?? const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          password: _sshPrivateKeyCtrl.text.isEmpty ? null : _sshPrivateKeyCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          isFavorite: _isFavorite,
          categoryId: _folderId,
          isDoubleEncrypted: _isDoubleEncrypted,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
          sshKeyMetadata: SshKeyMetadata(
            privateKey: _sshPrivateKeyCtrl.text.trim(),
            publicKey: _sshPublicKeyCtrl.text.trim(),
            passphrase: _sshPassphraseCtrl.text.isEmpty ? null : _sshPassphraseCtrl.text.trim(),
            keyType: _sshKeyType,
          ),
        );

      case CredentialType.passkey:
        return _existing!.copyWith(updatedAt: now);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _saveAnimCtrl.forward();
    await _saveAnimCtrl.reverse();
    setState(() => _isLoading = true);

    var credential = _buildCredential();
    try {
      if (_isDoubleEncrypted) {
        final pin = _secondaryPinCtrl.text.trim();
        if (pin.isEmpty && _existing == null) {
          throw Exception('Debes ingresar un PIN secundario para el cifrado doble');
        }
        
        if (pin.isNotEmpty) {
          final doubleEnvelopeService = getIt<DoubleEnvelopeService>();
          
          String? encryptedPassword;
          if (credential.password != null && !credential.password!.startsWith('double_enc_v1:')) {
            encryptedPassword = await doubleEnvelopeService.encryptField(
              plaintext: credential.password!,
              pin: pin,
            );
          } else {
            encryptedPassword = credential.password;
          }
          
          SshKeyMetadata? encryptedSshMetadata;
          if (credential.sshKeyMetadata != null) {
            final ssh = credential.sshKeyMetadata!;
            final encPriv = ssh.privateKey.startsWith('double_enc_v1:')
                ? ssh.privateKey
                : await doubleEnvelopeService.encryptField(plaintext: ssh.privateKey, pin: pin);
            final encPass = (ssh.passphrase != null && !ssh.passphrase!.startsWith('double_enc_v1:'))
                ? await doubleEnvelopeService.encryptField(plaintext: ssh.passphrase!, pin: pin)
                : ssh.passphrase;
            encryptedSshMetadata = ssh.copyWith(
              privateKey: encPriv,
              passphrase: encPass,
            );
          }
          
          credential = credential.copyWith(
            password: encryptedPassword,
            sshKeyMetadata: encryptedSshMetadata,
            isDoubleEncrypted: true,
          );
          
          if (_savePinBiometrically) {
            await doubleEnvelopeService.savePinToSecureStorage(
              credentialId: credential.id,
              pin: pin,
            );
          } else {
            await doubleEnvelopeService.deletePinFromSecureStorage(credential.id);
          }
        }
      } else {
        if (_existing?.isDoubleEncrypted == true) {
          final pin = _secondaryPinCtrl.text.trim();
          if (pin.isEmpty) {
            throw Exception('Ingresa el PIN secundario para desactivar el cifrado doble');
          }
          final doubleEnvelopeService = getIt<DoubleEnvelopeService>();
          
          String? decryptedPassword;
          if (credential.password != null && credential.password!.startsWith('double_enc_v1:')) {
            decryptedPassword = await doubleEnvelopeService.decryptField(
              encryptedValue: credential.password!,
              pin: pin,
            );
          } else {
            decryptedPassword = credential.password;
          }
          
          SshKeyMetadata? decryptedSshMetadata;
          if (credential.sshKeyMetadata != null) {
            final ssh = credential.sshKeyMetadata!;
            final decPriv = ssh.privateKey.startsWith('double_enc_v1:')
                ? await doubleEnvelopeService.decryptField(encryptedValue: ssh.privateKey, pin: pin)
                : ssh.privateKey;
            final decPass = (ssh.passphrase != null && ssh.passphrase!.startsWith('double_enc_v1:'))
                ? await doubleEnvelopeService.decryptField(encryptedValue: ssh.passphrase!, pin: pin)
                : ssh.passphrase;
            decryptedSshMetadata = ssh.copyWith(
              privateKey: decPriv,
              passphrase: decPass,
            );
          }
          
          credential = credential.copyWith(
            password: decryptedPassword,
            sshKeyMetadata: decryptedSshMetadata,
            isDoubleEncrypted: false,
          );
          
          await doubleEnvelopeService.deletePinFromSecureStorage(credential.id);
        }
      }

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

  Future<void> _generateSshKey() async {
    setState(() => _isGeneratingSshKey = true);
    HapticFeedback.mediumImpact();
    try {
      final generator = getIt<SshKeyGeneratorService>();
      final result = await generator.generateEd25519KeyPair(
        comment: _titleCtrl.text.trim().isEmpty
            ? 'solokey-generated'
            : _titleCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
      );
      if (mounted) {
        setState(() {
          _sshPrivateKeyCtrl.text = result.privateKey;
          _sshPublicKeyCtrl.text = result.publicKey;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Par de llaves Ed25519 generado'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      _showError('Error al generar la llave SSH.');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingSshKey = false);
      }
    }
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
            TypeSelectorPremium(
              selected: _type,
              isEditing: isEdit,
              onChanged: (t) => setState(() {
                _type = t;
                _showGenerator = false;
              }),
            ),
            const SizedBox(height: 24),

            FormSection(
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
                FavoriteToggle(
                  value: _isFavorite,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _isFavorite = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildFieldsByType(),

            if (_type != CredentialType.totp) ...[
              const SizedBox(height: 16),
              FormSection(
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

            const SizedBox(height: 16),
            _buildDoubleEncryptionSection(),

            const SizedBox(height: 16),
            FormSection(
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
                          builder: (_) => FolderPickerSheet(selectedFolderId: _folderId),
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

            ScaleTransition(
              scale: _saveScale,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : SaveButton(
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
    CredentialType.sshKey     => 'ej. Servidor Produccion, GitHub SSH Key',
  };

  IconData _typeIcon(CredentialType t) => switch (t) {
    CredentialType.password   => Icons.lock_rounded,
    CredentialType.apiKey     => Icons.key_rounded,
    CredentialType.secureNote => Icons.note_rounded,
    CredentialType.totp       => Icons.access_time_rounded,
    CredentialType.passkey    => Icons.fingerprint_rounded,
    CredentialType.sshKey     => Icons.terminal_rounded,
  };

  Color _typeColor(CredentialType t) => switch (t) {
    CredentialType.password   => AppColors.typePassword,
    CredentialType.apiKey     => AppColors.typeApiKey,
    CredentialType.secureNote => AppColors.typeNote,
    CredentialType.totp       => AppColors.typeTotp,
    CredentialType.passkey    => AppColors.typePasskey,
    CredentialType.sshKey     => AppColors.typeSshKey,
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
          CredentialType.sshKey   => _buildSshKeyFields(),
        },
      ),
    );
  }

  Widget _buildPasswordFields() {
    return FormSection(
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
        PasswordRowWidget(
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
    return FormSection(
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
        PasswordRowWidget(
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
    return FormSection(
      icon: Icons.access_time_rounded,
      accentColor: AppColors.typeTotp,
      title: 'Configuración 2FA',
      children: [
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
    return FormSection(
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

  Widget _buildSshKeyFields() {
    return FormSection(
      icon: Icons.terminal_rounded,
      accentColor: AppColors.typeSshKey,
      title: 'Configuracion de Llave SSH',
      children: [
        DropdownButtonFormField<String>(
          value: _sshKeyType,
          style: const TextStyle(color: Colors.white),
          dropdownColor: AppColors.drawer,
          decoration: const InputDecoration(
            labelText: 'Tipo de Llave',
            prefixIcon: Icon(Icons.vpn_key_outlined, size: 18, color: AppColors.textMuted),
          ),
          items: const [
            DropdownMenuItem(value: 'Ed25519', child: Text('Ed25519')),
            DropdownMenuItem(value: 'RSA', child: Text('RSA')),
            DropdownMenuItem(value: 'ECDSA', child: Text('ECDSA')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _sshKeyType = val);
          },
        ),
        if (_sshKeyType == 'Ed25519') ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _isGeneratingSshKey
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(color: AppColors.typeSshKey, strokeWidth: 2.5),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: _generateSshKey,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('Generar par de llaves Ed25519'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.typeSshKey,
                      side: const BorderSide(color: AppColors.typeSshKey, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
          ),
        ],
        const SizedBox(height: 14),
        TextFormField(
          controller: _sshPrivateKeyCtrl,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Llave Privada',
            hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.security_rounded, size: 18, color: AppColors.textMuted),
          ),
          validator: (v) =>
              _type == CredentialType.sshKey && (v == null || v.trim().isEmpty) ? 'La llave privada es requerida' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _sshPublicKeyCtrl,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Llave Publica (Opcional)',
            hintText: 'ssh-ed25519 AAAA...',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.public_rounded, size: 18, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),
        SecureTextField(
          controller: _sshPassphraseCtrl,
          label: 'Passphrase de la Llave (Opcional)',
        ),
      ],
    );
  }

  Widget _buildDoubleEncryptionSection() {
    if (_type == CredentialType.passkey) return const SizedBox.shrink();

    return FormSection(
      icon: Icons.enhanced_encryption_rounded,
      accentColor: AppColors.secondary,
      title: 'Cifrado de Sobre Doble',
      children: [
        SwitchListTile(
          value: _isDoubleEncrypted,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() {
              _isDoubleEncrypted = v;
              if (!v) {
                _secondaryPinCtrl.clear();
                _savePinBiometrically = false;
              }
            });
          },
          title: const Text('Activar Cifrado Doble', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: const Text(
            'Protege los secretos de este registro con un PIN secundario. Se cifraran adicionalmente.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          activeColor: AppColors.secondary,
          contentPadding: EdgeInsets.zero,
        ),
        if (_isDoubleEncrypted) ...[
          const SizedBox(height: 14),
          SecureTextField(
            controller: _secondaryPinCtrl,
            label: _existing?.isDoubleEncrypted == true
                ? 'PIN Secundario (Dejar vacio para mantener actual o ingresar para cambiar)'
                : 'PIN Secundario',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (_isDoubleEncrypted && _existing == null && (v == null || v.trim().isEmpty)) {
                return 'El PIN secundario es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _savePinBiometrically,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _savePinBiometrically = v);
            },
            title: const Text('Desbloqueo biometrico', style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text(
              'Guardar el PIN cifrado para desbloquear rapidamente con huella/rostro.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            activeColor: AppColors.secondary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ],
    );
  }
}
