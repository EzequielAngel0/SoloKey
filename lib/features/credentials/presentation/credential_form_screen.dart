import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../l10n/app_localizations.dart';
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
  List<CustomField> _customFields = [];

  // Password Rotation Reminder state
  String _rotationInterval = 'none';
  int? _customRotationDays;
  DateTime? _lastRotationPromptedAt;
  final _customRotationDaysCtrl = TextEditingController();

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
    if (widget.existingId != null) {
      _loadExisting();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ResponsiveLayout.isDesktop(context)) {
          final activeFolderId = ref.read(desktopSelectedFolderIdProvider);
          if (activeFolderId != null) {
            setState(() {
              _folderId = activeFolderId;
            });
          }
        }
      });
    }
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
      _customFields = _existing!.customFields
          .where((f) => f.label != 'scopes' && f.label != 'issuer')
          .toList();
      _rotationInterval = _existing!.rotationInterval;
      _customRotationDays = _existing!.customRotationDays;
      _lastRotationPromptedAt = _existing!.lastRotationPromptedAt;
      _customRotationDaysCtrl.text = _customRotationDays?.toString() ?? '';
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
      _secondaryPinCtrl, _customRotationDaysCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Credential _buildCredential() {
    final now = DateTime.now();

    // Check if secret was rotated to reset lastRotationPromptedAt
    bool isPasswordChanged = false;
    if (_existing != null) {
      if (_type == CredentialType.password && _passwordCtrl.text != _existing!.password) {
        isPasswordChanged = true;
      } else if (_type == CredentialType.apiKey && _apiKeyCtrl.text != _existing!.password) {
        isPasswordChanged = true;
      } else if (_type == CredentialType.sshKey && _sshPrivateKeyCtrl.text != _existing!.password) {
        isPasswordChanged = true;
      }
    }
    final resolvedLastPrompted = isPasswordChanged ? null : _lastRotationPromptedAt;

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
          customFields: _customFields,
          isFavorite: _isFavorite,
          categoryId: _folderId,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
          rotationInterval: _rotationInterval,
          customRotationDays: _customRotationDays,
          lastRotationPromptedAt: resolvedLastPrompted,
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
          customFields: [
            ..._customFields,
            if (_scopesCtrl.text.trim().isNotEmpty)
              CustomField(label: 'scopes', value: _scopesCtrl.text.trim()),
          ],
          isFavorite: _isFavorite,
          categoryId: _folderId,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
          rotationInterval: _rotationInterval,
          customRotationDays: _customRotationDays,
          lastRotationPromptedAt: resolvedLastPrompted,
        );

      case CredentialType.secureNote:
        return Credential(
          id: _existing?.id ?? const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          customFields: _customFields,
          isFavorite: _isFavorite,
          categoryId: _folderId,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
          rotationInterval: _rotationInterval,
          customRotationDays: _customRotationDays,
          lastRotationPromptedAt: resolvedLastPrompted,
        );

      case CredentialType.totp:
        return Credential(
          id: _existing?.id ?? const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          password: _totpSecretCtrl.text.isEmpty ? null : _totpSecretCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          customFields: [
            ..._customFields,
            if (_totpIssuerCtrl.text.trim().isNotEmpty)
              CustomField(label: 'issuer', value: _totpIssuerCtrl.text.trim()),
          ],
          isFavorite: _isFavorite,
          categoryId: _folderId,
          createdAt: _existing?.createdAt ?? now,
          updatedAt: now,
          rotationInterval: _rotationInterval,
          customRotationDays: _customRotationDays,
          lastRotationPromptedAt: resolvedLastPrompted,
        );

      case CredentialType.sshKey:
        return Credential(
          id: _existing?.id ?? const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          password: _sshPrivateKeyCtrl.text.isEmpty ? null : _sshPrivateKeyCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          customFields: _customFields,
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
          rotationInterval: _rotationInterval,
          customRotationDays: _customRotationDays,
          lastRotationPromptedAt: resolvedLastPrompted,
        );

      case CredentialType.passkey:
        return _existing!.copyWith(
          updatedAt: now,
          rotationInterval: _rotationInterval,
          customRotationDays: _customRotationDays,
          lastRotationPromptedAt: resolvedLastPrompted,
        );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    await _saveAnimCtrl.forward();
    await _saveAnimCtrl.reverse();
    setState(() => _isLoading = true);

    var credential = _buildCredential();
    try {
      if (_isDoubleEncrypted) {
        final pin = _secondaryPinCtrl.text.trim();
        if (pin.isEmpty && _existing == null) {
          throw Exception(l10n.formErrPinRequiredEnable);
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
          
          final List<CustomField> encryptedCustomFields = [];
          for (final field in credential.customFields) {
            if (field.isSecret && !field.value.startsWith('double_enc_v1:')) {
              final encValue = await doubleEnvelopeService.encryptField(
                plaintext: field.value,
                pin: pin,
              );
              encryptedCustomFields.add(field.copyWith(value: encValue));
            } else {
              encryptedCustomFields.add(field);
            }
          }

          credential = credential.copyWith(
            password: encryptedPassword,
            sshKeyMetadata: encryptedSshMetadata,
            customFields: encryptedCustomFields,
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
            throw Exception(l10n.formErrPinRequiredDisable);
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

          final List<CustomField> decryptedCustomFields = [];
          for (final field in credential.customFields) {
            if (field.isSecret && field.value.startsWith('double_enc_v1:')) {
              final decValue = await doubleEnvelopeService.decryptField(
                encryptedValue: field.value,
                pin: pin,
              );
              decryptedCustomFields.add(field.copyWith(value: decValue));
            } else {
              decryptedCustomFields.add(field);
            }
          }
          
          credential = credential.copyWith(
            password: decryptedPassword,
            sshKeyMetadata: decryptedSshMetadata,
            customFields: decryptedCustomFields,
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
                  _existing == null ? l10n.formCreated : l10n.formSaved,
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
        if (ResponsiveLayout.isDesktop(context)) {
          ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.details;
          ref.read(desktopSelectedCredentialIdProvider.notifier).state = credential.id;
        } else {
          context.pop();
        }
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonErrorDetail('$e')),
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
    final l10n = AppLocalizations.of(context);
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code == null) return;

    try {
      final uri = Uri.parse(code);
      if (uri.scheme.toLowerCase() != 'otpauth') {
        _showError(l10n.formQrNotTotp);
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
            content: Row(
              children: [
                const Icon(Icons.qr_code_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(l10n.formQrScanned),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        _showError(l10n.formQrNoSecret);
      }
    } catch (e) {
      _showError(l10n.formQrReadError);
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
    final l10n = AppLocalizations.of(context);
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
            content: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(l10n.formSshGenerated),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      _showError(l10n.formSshGenError);
    } finally {
      if (mounted) {
        setState(() => _isGeneratingSshKey = false);
      }
    }
  }

  Widget _buildCustomFieldsSection() {
    if (_type == CredentialType.passkey) return const SizedBox.shrink();

    final typeColor = _typeColor(_type);
    final l10n = AppLocalizations.of(context);

    return FormSection(
      icon: Icons.add_circle_outline_rounded,
      accentColor: typeColor,
      title: l10n.formCustomFieldsTitle,
      children: [
        if (_customFields.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              l10n.formNoCustomFields,
              style: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
            ),
          ),
        ...List.generate(_customFields.length, (index) {
          final field = _customFields[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              field.label,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (field.isSecret)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.formSecretBadge,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        field.isSecret ? '••••••••••••' : field.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textMuted),
                  onPressed: () => _showCustomFieldDialog(index: index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _customFields.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showCustomFieldDialog,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(l10n.formAddField),
            style: OutlinedButton.styleFrom(
              foregroundColor: typeColor,
              side: BorderSide(color: typeColor, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCustomFieldDialog({int? index}) async {
    final l10n = AppLocalizations.of(context);
    final isEditing = index != null;
    final labelCtrl = TextEditingController(text: isEditing ? _customFields[index].label : '');
    final valueCtrl = TextEditingController(text: isEditing ? _customFields[index].value : '');
    bool isSecret = isEditing ? _customFields[index].isSecret : false;

    // Check if the current value is double encrypted and decrypt it for editing
    if (isEditing && _existing?.isDoubleEncrypted == true && valueCtrl.text.startsWith('double_enc_v1:')) {
      final pin = _secondaryPinCtrl.text.trim();
      if (pin.isNotEmpty) {
        try {
          final plain = await getIt<DoubleEnvelopeService>().decryptField(
            encryptedValue: valueCtrl.text,
            pin: pin,
          );
          valueCtrl.text = plain;
        } catch (_) {}
      }
    }

    final dialogFormKey = GlobalKey<FormState>();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.drawer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEditing ? l10n.formEditField : l10n.formNewCustomField,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: labelCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: l10n.formFieldNameLabel,
                        hintText: l10n.formFieldNameHint,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? l10n.formNameRequired : null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: valueCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: l10n.formFieldValueLabel,
                        hintText: l10n.formFieldValueHint,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? l10n.formValueRequired : null,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isSecret,
                      activeColor: _typeColor(_type),
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.formSecretField, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(
                        l10n.formSecretFieldSub,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setDialogState(() => isSecret = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonCancel, style: const TextStyle(color: AppColors.textDisabled)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _typeColor(_type),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (!dialogFormKey.currentState!.validate()) return;
                    
                    final newField = CustomField(
                      label: labelCtrl.text.trim(),
                      value: valueCtrl.text.trim(),
                      isSecret: isSecret,
                    );
                    
                    setState(() {
                      if (isEditing) {
                        _customFields[index] = newField;
                      } else {
                        _customFields.add(newField);
                      }
                    });
                    
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? l10n.commonSave : l10n.formAdd),
                ),
              ],
            );
          },
        );
      },
    );

    labelCtrl.dispose();
    valueCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing != null;
    final typeColor = _typeColor(_type);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: VaultAppBar(
        title: isEdit ? l10n.formEditTitle : l10n.formNewTitle,
        leading: ResponsiveLayout.isDesktop(context)
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  if (isEdit) {
                    ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.details;
                  } else {
                    ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.none;
                  }
                },
              )
            : null,
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                isEdit ? l10n.commonSave : l10n.commonCreate,
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
              title: l10n.formSectionIdentification,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: l10n.formTitleLabel,
                    hintText: _titleHintFor(l10n),
                    prefixIcon: Icon(_typeIcon(_type), size: 18, color: typeColor.withValues(alpha: 0.7)),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.formFieldRequired : null,
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
                title: _type == CredentialType.secureNote ? l10n.formSectionContent : l10n.formSectionNotes,
                children: [
                  TextFormField(
                    controller: _notesCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: _type == CredentialType.secureNote ? 10 : 4,
                    decoration: InputDecoration(
                      labelText: _type == CredentialType.secureNote
                          ? l10n.formSecureContentLabel
                          : l10n.formNotesLabel,
                      hintText: _type == CredentialType.secureNote
                          ? l10n.formSecureContentHint
                          : l10n.formNotesHint,
                      alignLabelWithHint: true,
                    ),
                    validator: _type == CredentialType.secureNote
                        ? (v) => v == null || v.trim().isEmpty
                            ? l10n.formContentRequired
                            : null
                        : null,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            _buildCustomFieldsSection(),

            const SizedBox(height: 16),
            _buildDoubleEncryptionSection(),

            const SizedBox(height: 16),
            _buildRotationReminderSection(),

            const SizedBox(height: 16),
            FormSection(
              icon: Icons.folder_rounded,
              accentColor: AppColors.textMuted,
              title: l10n.formSectionOrganization,
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
                        decoration: InputDecoration(
                          labelText: l10n.formFolderLabel,
                          prefixIcon: const Icon(Icons.folder_outlined, color: AppColors.textMuted),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                currentFolder?.name ?? l10n.formMainVault,
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
                      label: isEdit ? l10n.formSaveChanges : l10n.formCreateCredential,
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

  String _titleHintFor(AppLocalizations l10n) => switch (_type) {
    CredentialType.password   => l10n.formHintPassword,
    CredentialType.apiKey     => l10n.formHintApiKey,
    CredentialType.secureNote => l10n.formHintSecureNote,
    CredentialType.totp       => l10n.formHintTotp,
    CredentialType.passkey    => l10n.formHintPasskey,
    CredentialType.sshKey     => l10n.formHintSshKey,
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
    final l10n = AppLocalizations.of(context);
    return FormSection(
      icon: Icons.lock_rounded,
      accentColor: AppColors.typePassword,
      title: l10n.formSectionLogin,
      children: [
        TextFormField(
          controller: _usernameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.formUserEmailLabel,
            hintText: l10n.formUserEmailHint,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textMuted),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        PasswordRowWidget(
          ctrl: _passwordCtrl,
          label: l10n.fieldPassword,
          showGenerator: _showGenerator,
          onToggleGenerator: (v) => setState(() => _showGenerator = v),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _websiteCtrl,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: l10n.formWebsiteLabel,
            hintText: l10n.formWebsiteHint,
            prefixIcon: const Icon(Icons.language_rounded, size: 18, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyFields() {
    final l10n = AppLocalizations.of(context);
    return FormSection(
      icon: Icons.key_rounded,
      accentColor: AppColors.typeApiKey,
      title: l10n.formSectionApi,
      children: [
        TextFormField(
          controller: _serviceCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.formServiceNameLabel,
            hintText: l10n.formServiceNameHint,
            prefixIcon: const Icon(Icons.cloud_rounded, size: 18, color: AppColors.textMuted),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.formFieldRequired : null,
        ),
        const SizedBox(height: 14),
        PasswordRowWidget(
          ctrl: _apiKeyCtrl,
          label: l10n.formApiKeyLabel,
          showGenerator: _showGenerator,
          onToggleGenerator: (v) => setState(() => _showGenerator = v),
          validator: (v) =>
              v == null || v.isEmpty ? l10n.formFieldRequired : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _endpointCtrl,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: l10n.formEndpointLabel,
            hintText: 'https://api.example.com/v1',
            prefixIcon: const Icon(Icons.link_rounded, size: 18, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _scopesCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.formScopesLabel,
            hintText: 'read:user, write:repo…',
            prefixIcon: const Icon(Icons.security_rounded, size: 18, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildTotpFields() {
    final l10n = AppLocalizations.of(context);
    return FormSection(
      icon: Icons.access_time_rounded,
      accentColor: AppColors.typeTotp,
      title: l10n.formSection2fa,
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
              Expanded(
                child: Text(
                  l10n.formTotpDesc,
                  style: const TextStyle(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: AppColors.typeTotp, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    l10n.formScanQr,
                    style: const TextStyle(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(l10n.formOrManually, style: const TextStyle(color: AppColors.textDisabled, fontSize: 11)),
            ),
            Expanded(child: Divider(color: AppColors.divider.withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _totpIssuerCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.formAccountIssuerLabel,
            hintText: l10n.formAccountIssuerHint,
            prefixIcon: const Icon(Icons.account_circle_outlined, size: 18, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),
        SecureTextField(
          controller: _totpSecretCtrl,
          label: l10n.formTotpSecretLabel,
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.formFieldRequired : null,
        ),
      ],
    );
  }

  Widget _buildPasskeyInfo() {
    final l10n = AppLocalizations.of(context);
    return FormSection(
      icon: Icons.fingerprint_rounded,
      accentColor: AppColors.typePasskey,
      title: l10n.formSectionPasskey,
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
          child: Column(
            children: [
              const Icon(Icons.fingerprint_rounded, color: AppColors.typePasskey, size: 32),
              const SizedBox(height: 12),
              Text(
                l10n.formPasskeyDesc,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.formPasskeyHint,
                style: const TextStyle(color: AppColors.textDisabled, fontSize: 12, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSshKeyFields() {
    final l10n = AppLocalizations.of(context);
    return FormSection(
      icon: Icons.terminal_rounded,
      accentColor: AppColors.typeSshKey,
      title: l10n.formSectionSsh,
      children: [
        DropdownButtonFormField<String>(
          value: _sshKeyType,
          style: const TextStyle(color: Colors.white),
          dropdownColor: AppColors.drawer,
          decoration: InputDecoration(
            labelText: l10n.fieldKeyType,
            prefixIcon: const Icon(Icons.vpn_key_outlined, size: 18, color: AppColors.textMuted),
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
                    label: Text(l10n.formGenerateSsh),
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
          decoration: InputDecoration(
            labelText: l10n.fieldPrivateKey,
            hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...',
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.security_rounded, size: 18, color: AppColors.textMuted),
          ),
          validator: (v) =>
              _type == CredentialType.sshKey && (v == null || v.trim().isEmpty) ? l10n.formPrivateKeyRequired : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _sshPublicKeyCtrl,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.formPublicKeyOptional,
            hintText: 'ssh-ed25519 AAAA...',
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.public_rounded, size: 18, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 14),
        SecureTextField(
          controller: _sshPassphraseCtrl,
          label: l10n.formKeyPassphraseOptional,
        ),
      ],
    );
  }

  Widget _buildDoubleEncryptionSection() {
    if (_type == CredentialType.passkey) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return FormSection(
      icon: Icons.enhanced_encryption_rounded,
      accentColor: AppColors.secondary,
      title: l10n.formSectionDoubleEnc,
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
          title: Text(l10n.formEnableDoubleEnc, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(
            l10n.formDoubleEncDesc,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          activeColor: AppColors.secondary,
          contentPadding: EdgeInsets.zero,
        ),
        if (_isDoubleEncrypted) ...[
          const SizedBox(height: 14),
          SecureTextField(
            controller: _secondaryPinCtrl,
            label: _existing?.isDoubleEncrypted == true
                ? l10n.formPinSecondaryEditLabel
                : l10n.formPinSecondaryLabel,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (_isDoubleEncrypted && _existing == null && (v == null || v.trim().isEmpty)) {
                return l10n.formPinSecondaryRequired;
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
            title: Text(l10n.formBiometricUnlock, style: const TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: Text(
              l10n.formBiometricUnlockSub,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            activeColor: AppColors.secondary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ],
    );
  }

  Widget _buildRotationReminderSection() {
    if (_type != CredentialType.password &&
        _type != CredentialType.apiKey &&
        _type != CredentialType.sshKey) {
      return const SizedBox.shrink();
    }

    final typeColor = _typeColor(_type);
    final l10n = AppLocalizations.of(context);

    return FormSection(
      icon: Icons.update_rounded,
      accentColor: typeColor,
      title: l10n.formSectionRotation,
      children: [
        DropdownButtonFormField<String>(
          value: _rotationInterval,
          style: const TextStyle(color: Colors.white),
          dropdownColor: AppColors.drawer,
          decoration: InputDecoration(
            labelText: l10n.formRotationLabel,
            prefixIcon: const Icon(Icons.alarm_rounded, size: 18, color: AppColors.textMuted),
          ),
          items: [
            DropdownMenuItem(value: 'none', child: Text(l10n.formRotNone)),
            DropdownMenuItem(value: 'monthly', child: Text(l10n.formRotMonthly)),
            DropdownMenuItem(value: 'quarterly', child: Text(l10n.rotationQuarterly)),
            DropdownMenuItem(value: 'semiAnnually', child: Text(l10n.rotationSemiAnnually)),
            DropdownMenuItem(value: 'custom', child: Text(l10n.formRotCustom)),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _rotationInterval = val;
                if (val != 'custom') {
                  _customRotationDays = null;
                  _customRotationDaysCtrl.clear();
                }
              });
            }
          },
        ),
        if (_rotationInterval == 'custom') ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: _customRotationDaysCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.formCustomDaysLabel,
              hintText: 'ej. 45, 90',
              prefixIcon: const Icon(Icons.date_range_rounded, size: 18, color: AppColors.textMuted),
            ),
            validator: (v) {
              if (_rotationInterval == 'custom') {
                if (v == null || v.trim().isEmpty) {
                  return l10n.formCustomDaysRequired;
                }
                final days = int.tryParse(v);
                if (days == null || days <= 0) {
                  return l10n.formCustomDaysInvalid;
                }
              }
              return null;
            },
            onChanged: (v) {
              _customRotationDays = int.tryParse(v);
            },
          ),
        ],
      ],
    );
  }
}
