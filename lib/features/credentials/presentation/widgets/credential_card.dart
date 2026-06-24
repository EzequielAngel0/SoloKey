import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otp/otp.dart';
import '../../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../../core/presentation/layouts/responsive_layout.dart';
import '../../../../core/utils/auth_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/clipboard_countdown.dart';
import '../../../../router/app_router.dart';
import '../../../../theme/app_palette.dart';
import '../../domain/entities/credential.dart';
import '../../application/credentials_provider.dart';
import 'credential_icon.dart';
import '../../../folders/application/folders_provider.dart';

/// Resolves the themed accent color for a credential [type].
Color credentialTypeColor(CredentialType type, AppPalette p) => switch (type) {
      CredentialType.password => p.typePassword,
      CredentialType.apiKey => p.typeApiKey,
      CredentialType.secureNote => p.typeNote,
      CredentialType.totp => p.typeTotp,
      CredentialType.passkey => p.typePasskey,
      CredentialType.sshKey => p.typeSshKey,
    };

class CredentialCard extends ConsumerWidget {
  const CredentialCard({super.key, required this.credential});

  final Credential credential;

  static const _typeIcons = {
    CredentialType.password: Icons.lock_rounded,
    CredentialType.apiKey: Icons.key_rounded,
    CredentialType.secureNote: Icons.note_rounded,
    CredentialType.totp: Icons.access_time_rounded,
    CredentialType.passkey: Icons.fingerprint_rounded,
    CredentialType.sshKey: Icons.terminal_rounded,
  };

  void _showOptionsSheet(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.drawer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  credential.title,
                  style: TextStyle(color: palette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(
                  credential.isFavorite ? Icons.star_border_rounded : Icons.star_rounded,
                  color: palette.warning,
                ),
                title: Text(
                  credential.isFavorite ? l10n.detailRemoveFavorite : l10n.detailAddFavorite,
                  style: TextStyle(color: palette.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(credentialsNotifierProvider.notifier).updateCredential(
                        credential.copyWith(isFavorite: !credential.isFavorite),
                      );
                },
              ),
              if (credential.username != null)
                ListTile(
                  leading: Icon(Icons.copy_rounded, color: palette.textPrimary),
                  title: Text(l10n.cardCopyUser, style: TextStyle(color: palette.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    await showClipboardCountdownSnackBar(
                      context: context,
                      label: l10n.fieldUsername,
                      value: credential.username!,
                    );
                  },
                ),
              if (credential.password != null && credential.type != CredentialType.totp)
                ListTile(
                  leading: Icon(Icons.password_rounded, color: palette.textPrimary),
                  title: Text(l10n.cardCopyPassword, style: TextStyle(color: palette.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    final auth = await AuthHelper.requireAuth(
                      context,
                      reason: l10n.cardCopyPasswordAuthReason,
                    );
                    if (!auth) return;
                    if (!context.mounted) return;

                    await showClipboardCountdownSnackBar(
                      context: context,
                      label: l10n.fieldPassword,
                      value: credential.password!,
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.drive_file_move_rounded, color: palette.textPrimary),
                title: Text(l10n.cardMoveToFolder, style: TextStyle(color: palette.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _moveFolder(context, ref);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_rounded, color: palette.textPrimary),
                title: Text(l10n.commonEdit, style: TextStyle(color: palette.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  if (ResponsiveLayout.isDesktop(context)) {
                    ref.read(desktopSelectedCredentialIdProvider.notifier).state = credential.id;
                    ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.edit;
                  } else {
                    context.push(AppRoutes.credentialEdit.replaceFirst(':id', credential.id));
                  }
                },
              ),
              Divider(color: palette.divider),
              ListTile(
                leading: Icon(Icons.delete_rounded, color: palette.danger),
                title: Text(l10n.commonDelete, style: TextStyle(color: palette.danger)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: palette.drawer,
                      title: Text(l10n.detailDeleteTitle, style: TextStyle(color: palette.textPrimary)),
                      content: Text(l10n.detailDeleteBody(credential.title), style: TextStyle(color: palette.textMuted)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.commonDelete, style: TextStyle(color: palette.danger)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(credentialsNotifierProvider.notifier).delete(credential.id);
                    if (context.mounted && ResponsiveLayout.isDesktop(context)) {
                      if (ref.read(desktopSelectedCredentialIdProvider) == credential.id) {
                        ref.read(desktopSelectedCredentialIdProvider.notifier).state = null;
                        ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.none;
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _moveFolder(BuildContext context, WidgetRef ref) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final folders = ref.read(foldersNotifierProvider).valueOrNull ?? [];

    final newCategoryId = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: palette.drawer,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(l10n.cardMoveToFolder, style: TextStyle(color: palette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.all_inbox_rounded, color: palette.textPrimary),
            title: Text(l10n.cardNoFolder, style: TextStyle(color: palette.textPrimary)),
            onTap: () => Navigator.pop(context, ''), // empty means null
          ),
          Divider(color: palette.divider),
          Expanded(
            child: ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, i) {
                final f = folders[i];
                final color = Color(int.tryParse('FF${f.colorHex.replaceFirst('#', '')}', radix: 16) ?? 0xFF6C63FF);
                return ListTile(
                  leading: Icon(Icons.folder_rounded, color: color),
                  title: Text(f.name, style: TextStyle(color: palette.textPrimary)),
                  trailing: credential.categoryId == f.id ? Icon(Icons.check_rounded, color: palette.accent) : null,
                  onTap: () => Navigator.pop(context, f.id),
                );
              },
            ),
          )
        ],
      ),
    );

    if (newCategoryId != null) {
      final updated = credential.copyWith(categoryId: newCategoryId.isEmpty ? null : newCategoryId);
      await ref.read(credentialsNotifierProvider.notifier).save(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.cardMovedSuccess),
          backgroundColor: palette.success,
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final icon = _typeIcons[credential.type] ?? Icons.lock_rounded;
    final color = credentialTypeColor(credential.type, palette);

    // Swipe-to-delete intentionally removed: deletion is available via the
    // long-press options sheet and the credential detail screen.
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (ResponsiveLayout.isDesktop(context)) {
              ref.read(desktopSelectedCredentialIdProvider.notifier).state = credential.id;
              ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.details;
            } else {
              context.push(
                AppRoutes.credentialDetail.replaceFirst(':id', credential.id),
              );
            }
          },
          onLongPress: () => _showOptionsSheet(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CredentialIcon(
                  credential: credential,
                  defaultIcon: icon,
                  color: color,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (credential.username != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          credential.username!,
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (credential.isDoubleEncrypted) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.enhanced_encryption_rounded,
                      color: palette.typeSshKey, size: 16),
                ],
                if (credential.isFavorite)
                  Icon(Icons.star_rounded,
                      color: palette.warning, size: 18),
                if (credential.type == CredentialType.totp)
                  _TotpVisualizer(credential: credential),
              ],
            ),
          ),
        ),
      );
  }
}

class _TotpVisualizer extends StatefulWidget {
  const _TotpVisualizer({required this.credential});
  final Credential credential;

  @override
  State<_TotpVisualizer> createState() => _TotpVisualizerState();
}

class _TotpVisualizerState extends State<_TotpVisualizer> {
  // Internal sentinel for an unparseable secret; rendered as a localized label.
  static const _kError = '__error__';

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
    if (remaining == 30) _updateCode();
    if (mounted) setState(() => _progress = remaining / 30.0);
  }

  void _updateCode() {
    final secret = widget.credential.password;
    if (secret == null || secret.isEmpty) return;
    try {
      final cleanSecret = secret.replaceAll(RegExp(r'\s|-'), '').toUpperCase();
      final code = OTP.generateTOTPCodeString(
        cleanSecret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
      if (mounted) {
        setState(() {
          _code = '${code.substring(0, 3)} ${code.substring(3)}';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _code = _kError);
    }
  }

  Future<void> _quickCopy(BuildContext context) async {
    if (_code == _kError || _code == '--- ---') return;
    final cleanCode = _code.replaceAll(' ', '');
    await showClipboardCountdownSnackBar(
      context: context,
      label: AppLocalizations.of(context).totpClipboardLabel,
      value: cleanCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final displayCode =
        _code == _kError ? AppLocalizations.of(context).totpInvalid : _code;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
      decoration: BoxDecoration(
        color: palette.drawer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayCode,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 2,
              backgroundColor: palette.background,
              color: palette.typeTotp,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.copy_rounded, color: palette.typeTotp, size: 16),
            onPressed: () => _quickCopy(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
