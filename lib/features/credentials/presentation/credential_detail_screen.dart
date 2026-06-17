import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otp/otp.dart';
import '../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/copy_feedback_button.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../application/credentials_provider.dart';
import '../domain/entities/credential.dart';
import '../../../core/utils/auth_helper.dart';
import '../../../shared/widgets/clipboard_countdown.dart';
import '../../../app/di/injection.dart';
import '../../../core/infrastructure/security/double_envelope_service.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../theme/app_palette.dart';

class CredentialDetailScreen extends ConsumerWidget {
  const CredentialDetailScreen({super.key, required this.credentialId});
  final String credentialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final credentialsAsync = ref.watch(credentialsNotifierProvider);

    return credentialsAsync.when(
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator(color: palette.accent)),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(l10n.commonErrorDetail('$e'))),
      ),
      data: (creds) {
        final cred = creds.where((c) => c.id == credentialId).firstOrNull;
        if (cred == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.detailNotFound)),
          );
        }
        return _DetailView(credential: cred);
      },
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.credential});
  final Credential credential;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: VaultAppBar(
        title: credential.title,
        leading: ResponsiveLayout.isDesktop(context) ? const SizedBox.shrink() : null,
        actions: [
          IconButton(
            icon: Icon(
              credential.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: palette.warning,
            ),
            tooltip: credential.isFavorite
                ? l10n.detailRemoveFavorite
                : l10n.detailAddFavorite,
            onPressed: () {
              ref.read(credentialsNotifierProvider.notifier).updateCredential(
                    credential.copyWith(isFavorite: !credential.isFavorite),
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              if (ResponsiveLayout.isDesktop(context)) {
                ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.edit;
              } else {
                context.push(
                  AppRoutes.credentialEdit.replaceFirst(':id', credential.id),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: palette.danger),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TypeBadge(type: credential.type),
          const SizedBox(height: 24),
          if (credential.username != null)
            _SecretTile(
              icon: Icons.person_rounded,
              label: l10n.fieldUsername,
              value: credential.username!,
              isSecret: false,
            ),
          if (credential.password != null && credential.type != CredentialType.sshKey)
            _SecretTile(
              icon: Icons.lock_rounded,
              label: l10n.fieldPassword,
              value: credential.password!,
              isSecret: true,
              isDoubleEncrypted: credential.isDoubleEncrypted,
              credentialId: credential.id,
            ),
          if (credential.website != null)
            _SecretTile(
              icon: Icons.language_rounded,
              label: l10n.fieldWebsite,
              value: credential.website!,
              isSecret: false,
            ),
          if (credential.notes != null && credential.notes!.isNotEmpty)
            _SecretTile(
              icon: Icons.notes_rounded,
              label: l10n.fieldNotes,
              value: credential.notes!,
              isSecret: false,
              multiline: true,
            ),
          if (credential.type == CredentialType.sshKey && credential.sshKeyMetadata != null) ...[
            _SecretTile(
              icon: Icons.vpn_key_rounded,
              label: l10n.fieldKeyType,
              value: credential.sshKeyMetadata!.keyType,
              isSecret: false,
            ),
            _SecretTile(
              icon: Icons.terminal_rounded,
              label: l10n.fieldPrivateKey,
              value: credential.sshKeyMetadata!.privateKey,
              isSecret: true,
              multiline: true,
              isDoubleEncrypted: credential.isDoubleEncrypted,
              credentialId: credential.id,
            ),
            if (credential.sshKeyMetadata!.publicKey.isNotEmpty)
              _SecretTile(
                icon: Icons.public_rounded,
                label: l10n.fieldPublicKey,
                value: credential.sshKeyMetadata!.publicKey,
                isSecret: false,
                multiline: true,
              ),
            if (credential.sshKeyMetadata!.passphrase != null && credential.sshKeyMetadata!.passphrase!.isNotEmpty)
              _SecretTile(
                icon: Icons.vpn_key_outlined,
                label: l10n.fieldKeyPassphrase,
                value: credential.sshKeyMetadata!.passphrase!,
                isSecret: true,
                isDoubleEncrypted: credential.isDoubleEncrypted,
                credentialId: credential.id,
              ),
          ],
          ...credential.customFields.map(
            (f) => _SecretTile(
              icon: Icons.code_rounded,
              label: f.label,
              value: f.value,
              isSecret: f.isSecret,
              isDoubleEncrypted: credential.isDoubleEncrypted,
              credentialId: credential.id,
            ),
          ),
          if (credential.type == CredentialType.totp &&
              credential.password != null)
            _TotpTile(secretId: credential.password!),
          _buildRotationStatusTile(context),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push(
                AppRoutes.passwordHistory.replaceAll(':id', credential.id),
              ),
              icon: const Icon(Icons.history_rounded, size: 18),
              label: Text(l10n.detailViewHistory),
              style: TextButton.styleFrom(
                foregroundColor: palette.accent,
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotationStatusTile(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    if (credential.rotationInterval == 'none') return const SizedBox.shrink();

    final intervalText = switch (credential.rotationInterval) {
      'monthly' => l10n.rotationMonthly,
      'quarterly' => l10n.rotationQuarterly,
      'semiAnnually' => l10n.rotationSemiAnnually,
      'custom' => l10n.rotationCustom(credential.customRotationDays ?? 30),
      _ => l10n.rotationNone,
    };

    final days = switch (credential.rotationInterval) {
      'monthly' => 30,
      'quarterly' => 90,
      'semiAnnually' => 180,
      'custom' => credential.customRotationDays ?? 30,
      _ => 0,
    };

    final lastChanged = credential.updatedAt;
    final nextRotation = lastChanged.add(Duration(days: days));
    final daysRemaining = nextRotation.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining <= 0;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue
            ? palette.danger.withValues(alpha: 0.1)
            : palette.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? palette.danger.withValues(alpha: 0.3)
              : palette.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.lock_clock_rounded,
            color: isOverdue ? palette.danger : palette.secondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue
                      ? l10n.rotationOverdueTitle
                      : l10n.rotationReminderTitle,
                  style: TextStyle(
                    color: isOverdue ? palette.danger : palette.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOverdue
                      ? l10n.rotationOverdueBody(days)
                      : l10n.rotationReminderBody(daysRemaining, intervalText),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.detailDeleteTitle,
            style: TextStyle(color: palette.textPrimary)),
        content: Text(
          l10n.detailDeleteBody(credential.title),
          style: TextStyle(color: palette.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete,
                style: TextStyle(color: palette.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!context.mounted) return;
      final auth = await AuthHelper.requireAuth(context, reason: l10n.detailDeleteAuthReason);
      if (!auth) return;

      await ref
          .read(credentialsNotifierProvider.notifier)
          .delete(credential.id);
      if (context.mounted) {
        if (ResponsiveLayout.isDesktop(context)) {
          ref.read(desktopSelectedCredentialIdProvider.notifier).state = null;
          ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.none;
        } else {
          context.pop();
        }
      }
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final CredentialType type;

  static String _label(AppLocalizations l10n, CredentialType type) =>
      switch (type) {
        CredentialType.password => l10n.typePassword,
        CredentialType.apiKey => l10n.typeApiKey,
        CredentialType.secureNote => l10n.typeSecureNote,
        CredentialType.totp => l10n.typeTotp,
        CredentialType.passkey => l10n.typePasskey,
        CredentialType.sshKey => l10n.typeSshKey,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final color = switch (type) {
      CredentialType.password => palette.typePassword,
      CredentialType.apiKey => palette.typeApiKey,
      CredentialType.secureNote => palette.typeNote,
      CredentialType.totp => palette.typeTotp,
      CredentialType.passkey => palette.typePasskey,
      CredentialType.sshKey => palette.typeSshKey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label(l10n, type),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SecretTile extends StatefulWidget {
  const _SecretTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSecret,
    this.multiline = false,
    this.isDoubleEncrypted = false,
    this.credentialId = '',
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isSecret;
  final bool multiline;
  final bool isDoubleEncrypted;
  final String credentialId;

  @override
  State<_SecretTile> createState() => _SecretTileState();
}

class _SecretTileState extends State<_SecretTile> {
  bool _revealed = false;
  String? _decryptedValue;
  bool _decrypting = false;

  Future<String?> _getPlainValue(BuildContext context) async {
    if (!widget.isDoubleEncrypted || !widget.value.startsWith('double_enc_v1:')) {
      return widget.value;
    }
    if (_decryptedValue != null) {
      return _decryptedValue;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _decrypting = true);
    try {
      final doubleEnvelopeService = getIt<DoubleEnvelopeService>();
      final bioService = getIt<BiometricAuthService>();

      final savedPin = await doubleEnvelopeService.getPinFromSecureStorage(widget.credentialId);
      if (savedPin != null) {
        final auth = await bioService.authenticate(
            reason: l10n.secretDecryptAuthReason);
        if (auth) {
          final plain = await doubleEnvelopeService.decryptField(
            encryptedValue: widget.value,
            pin: savedPin,
          );
          if (mounted) setState(() => _decryptedValue = plain);
          return plain;
        }
      }

      if (!context.mounted) return null;
      final pin = await _showPinDialog(context);
      if (pin != null && pin.isNotEmpty) {
        final plain = await doubleEnvelopeService.decryptField(
          encryptedValue: widget.value,
          pin: pin,
        );
        if (mounted) setState(() => _decryptedValue = plain);
        return plain;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.secretDecryptError('$e')),
            backgroundColor: context.palette.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _decrypting = false);
    }
    return null;
  }

  Future<String?> _showPinDialog(BuildContext context) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (diagContext) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.pinDialogTitle, style: TextStyle(color: palette.textPrimary, fontSize: 16)),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            labelText: l10n.pinDialogLabel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(diagContext, controller.text),
            child: Text(l10n.commonAccept),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    if (widget.isSecret) {
      final auth = await AuthHelper.requireAuth(context);
      if (!auth) return;
    }
    if (!context.mounted) return;

    final plain = await _getPlainValue(context);
    if (plain == null || !context.mounted) return;

    await showClipboardCountdownSnackBar(
      context: context,
      label: widget.label,
      value: plain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = _decrypting
        ? AppLocalizations.of(context).secretDecrypting
        : (widget.isSecret && !_revealed ? '••••••••••••' : (_decryptedValue ?? widget.value));

    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.icon, color: palette.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    letterSpacing: widget.isSecret && !_revealed && !_decrypting ? 2 : 0,
                  ),
                  maxLines: widget.multiline ? null : 1,
                  overflow: widget.multiline
                      ? null
                      : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.isSecret)
            IconButton(
              icon: Icon(
                _revealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: palette.textMuted,
                size: 18,
              ),
              onPressed: () async {
                if (_revealed) {
                  setState(() {
                    _revealed = false;
                    _decryptedValue = null; // Clear from memory when hidden!
                  });
                } else {
                  final plain = await _getPlainValue(context);
                  if (plain != null) {
                    setState(() => _revealed = true);
                  }
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 8),
          CopyFeedbackButton(onCopy: () => _copy(context)),
        ],
      ),
    );
  }
}

class _TotpTile extends StatefulWidget {
  const _TotpTile({required this.secretId});
  final String secretId;

  @override
  State<_TotpTile> createState() => _TotpTileState();
}

class _TotpTileState extends State<_TotpTile> {
  // Internal sentinel for an unparseable secret; rendered as a localized label.
  static const _kInvalid = '__invalid__';

  late Timer _timer;
  String _code = '--- ---';
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _updateCode();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateProgress());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateProgress() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = 30 - ((now / 1000).round() % 30);
    
    // Si acaba de reiniciar, recalcula el código
    if (remaining == 30) {
      _updateCode();
    }
    
    setState(() {
      _progress = remaining / 30.0;
    });
  }

  void _updateCode() {
    try {
      // Limpiar secret de espacios o guiones
      final cleanSecret = widget.secretId.replaceAll(RegExp(r'\s|-'), '').toUpperCase();
      final code = OTP.generateTOTPCodeString(
        cleanSecret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
      // Poner espacio en medio
      setState(() {
        _code = '${code.substring(0, 3)} ${code.substring(3)}';
      });
    } catch (_) {
      setState(() {
        _code = _kInvalid;
      });
    }
  }

  Future<void> _copy(BuildContext context) async {
    if (_code == _kInvalid || _code == '--- ---') return;

    final l10n = AppLocalizations.of(context);
    final auth = await AuthHelper.requireAuth(context);
    if (!auth) return;
    if (!context.mounted) return;

    final cleanCode = _code.replaceAll(' ', '');
    await showClipboardCountdownSnackBar(
      context: context,
      label: l10n.totpClipboardLabel,
      value: cleanCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final displayCode = _code == _kInvalid ? l10n.totpInvalid : _code;
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.typeTotp.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.typeTotp.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.timer_rounded, color: palette.typeTotp, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.totpTitle,
                  style: TextStyle(
                    color: palette.typeTotp,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              CopyFeedbackButton(
                onCopy: () => _copy(context),
                color: palette.typeTotp,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayCode,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  value: _progress,
                  backgroundColor: palette.drawer,
                  color: palette.typeTotp,
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
