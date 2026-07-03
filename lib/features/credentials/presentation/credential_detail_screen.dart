import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otp/otp.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/copy_feedback_button.dart';
import '../../../shared/widgets/detail_group.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../application/credentials_provider.dart';
import '../application/credential_health_provider.dart';
import '../../../shared/widgets/status_chip.dart';
import '../domain/entities/credential.dart';
import 'widgets/credential_card.dart' show credentialTypeColor, credentialTypeLabel;
import '../../../core/utils/auth_helper.dart';
import '../../../shared/widgets/clipboard_countdown.dart';
import '../../../app/di/injection.dart';
import '../../../core/infrastructure/security/double_envelope_service.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';

// ── Type helpers ──────────────────────────────────────────────────────────────
// Color + localized label are shared with the card (credentialTypeColor /
// credentialTypeLabel in credential_card.dart) so wording stays consistent.
// Only the detail-specific icon mapping lives here.
IconData _typeIcon(CredentialType t) => switch (t) {
      CredentialType.password => Icons.lock_rounded,
      CredentialType.apiKey => Icons.key_rounded,
      CredentialType.secureNote => Icons.note_rounded,
      CredentialType.totp => Icons.timer_rounded,
      CredentialType.passkey => Icons.fingerprint_rounded,
      CredentialType.sshKey => Icons.terminal_rounded,
    };

/// Normalizes a user-entered site into a launchable https URL and opens it in
/// the external browser. Shows a localized error snackbar on failure.
Future<void> _launchSite(BuildContext context, String raw) async {
  final l10n = AppLocalizations.of(context);
  var url = raw.trim();
  if (url.isEmpty) return;
  if (!url.contains('://')) url = 'https://$url';
  final uri = Uri.tryParse(url);
  var ok = false;
  if (uri != null) {
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.detailOpenSiteError),
        backgroundColor: context.palette.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

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
        body: Center(child: CircularProgressIndicator(color: palette.primary)),
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

    final primary = _primaryRows(context, l10n);
    final advanced = _advancedRows(context, l10n);
    final health = ref.watch(credentialHealthProvider)[credential.id];

    return Scaffold(
      appBar: VaultAppBar(
        title: credential.title,
        // Desktop has no router back stack for the right pane, so give it an
        // explicit close that clears the selection (mobile keeps the default
        // router back arrow).
        leading: ResponsiveLayout.isDesktop(context)
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.commonClose,
                onPressed: () {
                  ref
                      .read(desktopSelectedCredentialIdProvider.notifier)
                      .state = null;
                  ref.read(desktopRightPaneModeProvider.notifier).state =
                      RightPaneMode.none;
                },
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              credential.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
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
            icon: Icon(
              credential.isHidden
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: palette.textMuted,
            ),
            tooltip: credential.isHidden ? l10n.detailUnhide : l10n.detailHide,
            onPressed: () {
              ref
                  .read(credentialsNotifierProvider.notifier)
                  .setHidden(credential.id, !credential.isHidden);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(credential.isHidden
                      ? l10n.detailUnhidden
                      : l10n.detailHidden),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              if (ResponsiveLayout.isDesktop(context)) {
                ref.read(desktopRightPaneModeProvider.notifier).state =
                    RightPaneMode.edit;
              } else {
                context.push(
                  AppRoutes.credentialEdit.replaceFirst(':id', credential.id),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: palette.danger),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _DetailHeader(credential: credential),
          if (health != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (health.contains(CredentialHealth.weak))
                  StatusChip(
                    label: l10n.strengthWeak,
                    color: palette.warning,
                    icon: Icons.warning_amber_rounded,
                  ),
                if (health.contains(CredentialHealth.reused))
                  StatusChip(
                    label: l10n.healthReused,
                    color: palette.danger,
                    icon: Icons.content_copy_rounded,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          // TOTP: the live code is the hero, first thing you see.
          if (credential.type == CredentialType.totp &&
              credential.password != null) ...[
            _TotpTile(
              secretId: credential.password!,
              issuer: credential.title,
              account: credential.username ?? '',
            ),
            const SizedBox(height: 14),
          ],
          if (primary.isNotEmpty) DetailGroup(children: primary),
          if (advanced.isNotEmpty) ...[
            SectionHeader(text: l10n.detailAdvanced),
            DetailGroup(children: advanced),
          ],
          _buildRotationStatusTile(context),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push(
                AppRoutes.passwordHistory.replaceAll(':id', credential.id),
              ),
              icon: const Icon(Icons.history_rounded, size: 18),
              label: Text(l10n.detailViewHistory),
              style: TextButton.styleFrom(
                foregroundColor: palette.primary,
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rows shown in the main (always-visible) group, ordered by type so the most
  /// useful field comes first. Secrets here (e.g. login password) reveal inline.
  List<Widget> _primaryRows(BuildContext context, AppLocalizations l10n) {
    final rows = <Widget>[];
    final c = credential;

    switch (c.type) {
      case CredentialType.sshKey:
        if (c.sshKeyMetadata != null) {
          rows.add(_DetailRow(
            icon: Icons.vpn_key_rounded,
            label: l10n.fieldKeyType,
            value: c.sshKeyMetadata!.keyType,
            isSecret: false,
          ));
          if (c.sshKeyMetadata!.publicKey.isNotEmpty) {
            rows.add(_DetailRow(
              icon: Icons.public_rounded,
              label: l10n.fieldPublicKey,
              value: c.sshKeyMetadata!.publicKey,
              isSecret: false,
              multiline: true,
              mono: true,
            ));
          }
        }
        break;
      case CredentialType.totp:
        if (c.username != null) {
          rows.add(_DetailRow(
            icon: Icons.person_rounded,
            label: l10n.fieldUsername,
            value: c.username!,
            isSecret: false,
          ));
        }
        break;
      case CredentialType.passkey:
        // Show the passkey's identifying metadata; the encrypted private-key
        // handle in [c.password] is an internal blob and is never surfaced.
        if (c.username != null) {
          rows.add(_DetailRow(
            icon: Icons.person_rounded,
            label: l10n.fieldUsername,
            value: c.username!,
            isSecret: false,
          ));
        }
        final m = c.passkeyMetadata;
        if (m != null) {
          rows.add(_DetailRow(
            icon: Icons.language_rounded,
            label: l10n.passkeyDomain,
            value: m.rpId,
            isSecret: false,
          ));
          final rpName = m.rpName;
          if (rpName != null && rpName.isNotEmpty) {
            rows.add(_DetailRow(
              icon: Icons.business_rounded,
              label: l10n.passkeyService,
              value: rpName,
              isSecret: false,
            ));
          }
          rows.add(_DetailRow(
            icon: Icons.badge_rounded,
            label: l10n.passkeyCredentialId,
            value: m.credentialId,
            isSecret: false,
            mono: true,
          ));
        }
        break;
      default:
        if (c.username != null) {
          rows.add(_DetailRow(
            icon: Icons.person_rounded,
            label: l10n.fieldUsername,
            value: c.username!,
            isSecret: false,
          ));
        }
        if (c.password != null) {
          rows.add(_DetailRow(
            icon: c.type == CredentialType.apiKey
                ? Icons.key_rounded
                : Icons.lock_rounded,
            label: c.type == CredentialType.apiKey
                ? l10n.typeApiKey
                : l10n.fieldPassword,
            value: c.password!,
            isSecret: true,
            mono: true,
            isDoubleEncrypted: c.isDoubleEncrypted,
            credentialId: c.id,
          ));
        }
    }

    if (c.website != null && c.website!.trim().isNotEmpty) {
      rows.add(_DetailRow(
        icon: Icons.language_rounded,
        label: l10n.fieldWebsite,
        value: c.website!,
        isSecret: false,
        openUrl: c.website,
      ));
    }

    // Custom fields (e.g. TOTP issuer, API scopes) go in the main group.
    for (final f in c.customFields) {
      rows.add(_DetailRow(
        icon: Icons.code_rounded,
        label: f.label,
        value: f.value,
        isSecret: f.isSecret,
        mono: f.isSecret,
        isDoubleEncrypted: c.isDoubleEncrypted,
        credentialId: c.id,
      ));
    }

    if (c.notes != null && c.notes!.isNotEmpty) {
      rows.add(_DetailRow(
        icon: Icons.notes_rounded,
        label: l10n.fieldNotes,
        value: c.notes!,
        isSecret: false,
        multiline: true,
      ));
    }

    return rows;
  }

  /// Sensitive material tucked under "Advanced": the TOTP seed and the SSH
  /// private key / passphrase. Hidden by default; reveal/copy require auth.
  List<Widget> _advancedRows(BuildContext context, AppLocalizations l10n) {
    final rows = <Widget>[];
    final c = credential;

    if (c.type == CredentialType.totp && c.password != null) {
      rows.add(_DetailRow(
        icon: Icons.key_rounded,
        label: l10n.detailTotpSecret,
        value: c.password!,
        isSecret: true,
        mono: true,
        isDoubleEncrypted: c.isDoubleEncrypted,
        credentialId: c.id,
      ));
    }

    if (c.type == CredentialType.sshKey && c.sshKeyMetadata != null) {
      rows.add(_DetailRow(
        icon: Icons.terminal_rounded,
        label: l10n.fieldPrivateKey,
        value: c.sshKeyMetadata!.privateKey,
        isSecret: true,
        multiline: true,
        mono: true,
        isDoubleEncrypted: c.isDoubleEncrypted,
        credentialId: c.id,
      ));
      final pass = c.sshKeyMetadata!.passphrase;
      if (pass != null && pass.isNotEmpty) {
        rows.add(_DetailRow(
          icon: Icons.vpn_key_outlined,
          label: l10n.fieldKeyPassphrase,
          value: pass,
          isSecret: true,
          mono: true,
          isDoubleEncrypted: c.isDoubleEncrypted,
          credentialId: c.id,
        ));
      }
    }

    return rows;
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
    final accent = isOverdue ? palette.danger : palette.secondary;

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.lock_clock_rounded,
            color: accent,
            size: 22,
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
                    color: accent,
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
        backgroundColor: palette.surface,
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
      final auth = await AuthHelper.requireAuth(context,
          reason: l10n.detailDeleteAuthReason);
      if (!auth) return;

      await ref
          .read(credentialsNotifierProvider.notifier)
          .delete(credential.id);
      if (context.mounted) {
        if (ResponsiveLayout.isDesktop(context)) {
          ref.read(desktopSelectedCredentialIdProvider.notifier).state = null;
          ref.read(desktopRightPaneModeProvider.notifier).state =
              RightPaneMode.none;
        } else {
          context.pop();
        }
      }
    }
  }
}

/// Compact header: type-colored avatar + title + type/subtitle line.
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.credential});
  final Credential credential;

  String? _subtitle() {
    if (credential.website != null && credential.website!.isNotEmpty) {
      return credential.website;
    }
    if (credential.username != null && credential.username!.isNotEmpty) {
      return credential.username;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final color = credentialTypeColor(credential.type, p);
    final subtitle = _subtitle();

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_typeIcon(credential.type), color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                credential.title,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      credentialTypeLabel(credential.type, l10n),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(color: p.textMuted, fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dense key/value row. Handles plain values, inline secrets (reveal + copy with
/// auth) and double-encrypted fields (PIN/biometric decrypt on demand).
class _DetailRow extends StatefulWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSecret,
    this.multiline = false,
    this.mono = false,
    this.isDoubleEncrypted = false,
    this.credentialId = '',
    this.openUrl,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isSecret;
  final bool multiline;
  final bool mono;
  final bool isDoubleEncrypted;
  final String credentialId;

  /// When set, an "open site" action is shown that launches this URL externally.
  final String? openUrl;

  @override
  State<_DetailRow> createState() => _DetailRowState();
}

class _DetailRowState extends State<_DetailRow> with WidgetsBindingObserver {
  // Revealed secrets auto-hide after this window (and immediately on background),
  // so plaintext never lingers on screen or in RAM.
  static const _revealHold = Duration(seconds: 30);

  bool _revealed = false;
  String? _decryptedValue;
  bool _decrypting = false;
  Timer? _hideTimer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Scrub any revealed plaintext the moment the app leaves the foreground.
    if (state != AppLifecycleState.resumed && _revealed) {
      _hideNow();
    }
  }

  /// Hides the value and wipes the decrypted plaintext from RAM. Single choke
  /// point for every hide path (manual toggle, countdown, background).
  void _hideNow() {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (!mounted) return;
    setState(() {
      _revealed = false;
      _decryptedValue = null;
      _secondsLeft = 0;
    });
  }

  void _startHideCountdown() {
    _hideTimer?.cancel();
    _secondsLeft = _revealHold.inSeconds;
    _hideTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) _hideNow();
    });
  }

  Future<String?> _getPlainValue(BuildContext context) async {
    if (!widget.isDoubleEncrypted ||
        !widget.value.startsWith('double_enc_v1:')) {
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

      final savedPin = await doubleEnvelopeService
          .getPinFromSecureStorage(widget.credentialId);
      if (savedPin != null) {
        final auth =
            await bioService.authenticate(reason: l10n.secretDecryptAuthReason);
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
        backgroundColor: palette.surface,
        title: Text(l10n.pinDialogTitle,
            style: TextStyle(color: palette.textPrimary, fontSize: 16)),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(labelText: l10n.pinDialogLabel),
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
    // Double-encrypted fields authenticate inside _getPlainValue (bio + PIN);
    // gating here too would prompt twice. Plain secrets have no inner gate.
    if (widget.isSecret && !widget.isDoubleEncrypted) {
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

  Future<void> _toggleReveal() async {
    if (_revealed) {
      _hideNow();
      return;
    }
    // Revealing a secret requires auth. Non double-encrypted values are returned
    // in the clear by _getPlainValue, so gate them here; double-encrypted ones
    // are authed inside _getPlainValue.
    if (widget.isSecret && !widget.isDoubleEncrypted) {
      final l10n = AppLocalizations.of(context);
      final auth = await AuthHelper.requireAuth(
        context,
        reason: l10n.detailRevealAuthReason,
      );
      if (!auth || !mounted) return;
    }
    final plain = await _getPlainValue(context);
    if (plain != null && mounted) {
      setState(() => _revealed = true);
      _startHideCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final hidden = widget.isSecret && !_revealed && !_decrypting;
    final display = _decrypting
        ? AppLocalizations.of(context).secretDecrypting
        : (hidden ? '••••••••••••' : (_decryptedValue ?? widget.value));

    final valueStyle = TextStyle(
      color: p.textPrimary,
      fontSize: 14,
      height: widget.multiline ? 1.45 : 1.2,
      fontFamily: (widget.mono || (widget.isSecret && !hidden))
          ? AppTheme.monoFamily
          : null,
      letterSpacing: hidden ? 2 : 0,
    );

    final labelWidget = Text(
      widget.label,
      style: TextStyle(
        color: p.textMuted,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final actions = <Widget>[
      if (widget.openUrl != null)
        Semantics(
          button: true,
          label: l10n.detailOpenSite,
          child: IconButton(
            icon: Icon(Icons.open_in_new_rounded, color: p.primary, size: 18),
            tooltip: l10n.detailOpenSite,
            onPressed: () => _launchSite(context, widget.openUrl!),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ),
      if (widget.isSecret && _revealed && _secondsLeft > 0)
        Semantics(
          label: l10n.detailHideCountdown(_secondsLeft),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: p.divider),
            ),
            child: Text(
              '${_secondsLeft}s',
              style: TextStyle(
                color: p.textMuted,
                fontSize: 10.5,
                fontFamily: AppTheme.monoFamily,
              ),
            ),
          ),
        ),
      if (widget.isSecret)
        Semantics(
          button: true,
          label: _revealed ? l10n.detailHideSecret : l10n.detailRevealSecret,
          child: IconButton(
            icon: Icon(
              _revealed
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: p.textMuted,
              size: 18,
            ),
            onPressed: _toggleReveal,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(left: 4, right: 2),
        child: Semantics(
          button: true,
          label: l10n.detailCopyField(widget.label),
          child: CopyFeedbackButton(onCopy: () => _copy(context)),
        ),
      ),
    ];

    if (widget.multiline) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: p.textMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(child: labelWidget),
                ...actions,
              ],
            ),
            const SizedBox(height: 8),
            Text(display, style: valueStyle),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          Icon(widget.icon, color: p.textMuted, size: 16),
          const SizedBox(width: 10),
          SizedBox(
            width: 84,
            child: labelWidget,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              display,
              style: valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// The live TOTP code — the hero of a TOTP credential's detail.
class _TotpTile extends StatefulWidget {
  const _TotpTile({
    required this.secretId,
    this.issuer = '',
    this.account = '',
  });

  final String secretId;

  /// Used to build the `otpauth://` URI for the QR export.
  final String issuer;
  final String account;

  @override
  State<_TotpTile> createState() => _TotpTileState();
}

class _TotpTileState extends State<_TotpTile> {
  // Internal sentinel for an unparseable secret; rendered as a localized label.
  static const _kInvalid = '__invalid__';

  late Timer _timer;
  String _code = '--- ---';
  double _progress = 1.0;
  int _remaining = 30;

  @override
  void initState() {
    super.initState();
    _updateCode();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateProgress());
  }

  @override
  void didUpdateWidget(covariant _TotpTile old) {
    super.didUpdateWidget(old);
    // Desktop reuses this State when the selected credential changes; recompute
    // so it doesn't keep showing the previous TOTP's code.
    if (old.secretId != widget.secretId) {
      _updateCode();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateProgress() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = 30 - ((now / 1000).round() % 30);
    if (remaining == 30) {
      _updateCode();
    }
    setState(() {
      _remaining = remaining;
      _progress = remaining / 30.0;
    });
  }

  void _updateCode() {
    try {
      final cleanSecret =
          widget.secretId.replaceAll(RegExp(r'\s|-'), '').toUpperCase();
      final code = OTP.generateTOTPCodeString(
        cleanSecret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
      setState(() {
        _code = '${code.substring(0, 3)} ${code.substring(3)}';
      });
    } catch (_) {
      setState(() {
        _code = _kInvalid;
      });
    }
  }

  String get _cleanSecret =>
      widget.secretId.replaceAll(RegExp(r'\s|-'), '').toUpperCase();

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

  /// Builds the standard `otpauth://totp/...` provisioning URI so another
  /// authenticator can import this seed by scanning the QR.
  String _otpauthUri() {
    final issuer = widget.issuer.trim();
    final account = widget.account.trim();
    final labelSource =
        account.isEmpty ? issuer : '$issuer:$account';
    final label = Uri.encodeComponent(labelSource.isEmpty ? 'TOTP' : labelSource);
    final params = <String>[
      'secret=$_cleanSecret',
      if (issuer.isNotEmpty) 'issuer=${Uri.encodeComponent(issuer)}',
      'algorithm=SHA1',
      'digits=6',
      'period=30',
    ];
    return 'otpauth://totp/$label?${params.join('&')}';
  }

  /// Shows the seed as a QR — sensitive, so it is gated behind auth and carries
  /// a privacy warning. The seed is never logged.
  Future<void> _showQr(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final auth = await AuthHelper.requireAuth(
      context,
      reason: l10n.detailTotpExportQrAuthReason,
    );
    if (!auth || !context.mounted) return;

    final p = context.palette;
    final uri = _otpauthUri();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.drawer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.detailTotpExportQrTitle,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // QR needs a light background to scan.
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: uri,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: p.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.detailTotpExportQrWarning,
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final accent = p.typeTotp;
    final invalid = _code == _kInvalid;
    final displayCode = invalid ? l10n.totpInvalid : _code;

    return Material(
      color: accent.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: invalid ? null : () => _copy(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.totpTitle.toUpperCase(),
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayCode,
                      style: TextStyle(
                        color: invalid ? p.danger : p.textPrimary,
                        fontSize: invalid ? 18 : 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: invalid ? 0 : 5,
                        fontFamily: AppTheme.monoFamily,
                      ),
                    ),
                  ),
                  if (!invalid) ...[
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(
                              value: _progress,
                              backgroundColor: accent.withValues(alpha: 0.2),
                              color: accent,
                              strokeWidth: 3,
                            ),
                          ),
                          Text(
                            '$_remaining',
                            style: TextStyle(
                              color: p.textBody,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppTheme.monoFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Semantics(
                      button: true,
                      label: l10n.detailTotpExportQr,
                      child: IconButton(
                        icon: Icon(Icons.qr_code_2_rounded,
                            color: accent, size: 20),
                        tooltip: l10n.detailTotpExportQr,
                        onPressed: () => _showQr(context),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 34, minHeight: 34),
                      ),
                    ),
                    CopyFeedbackButton(
                      onCopy: () => _copy(context),
                      color: accent,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
