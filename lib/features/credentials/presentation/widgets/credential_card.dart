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
import '../../../../shared/widgets/status_chip.dart';
import '../../../../shared/widgets/type_badge.dart';
import '../../../../theme/app_palette.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/credential.dart';
import '../../application/credentials_provider.dart';
import '../../application/credential_health_provider.dart';
import 'credential_icon.dart';
import 'folder_picker_sheet.dart';

/// Resolves the themed accent color for a credential [type].
Color credentialTypeColor(CredentialType type, AppPalette p) => switch (type) {
      CredentialType.password => p.typePassword,
      CredentialType.apiKey => p.typeApiKey,
      CredentialType.secureNote => p.typeNote,
      CredentialType.totp => p.typeTotp,
      CredentialType.passkey => p.typePasskey,
      CredentialType.sshKey => p.typeSshKey,
    };

/// Short, localized label for a credential [type] — reused by the card subtitle
/// fallback, the type badge and (a11y) semantics. Kept in one place so the
/// wording stays consistent everywhere a type is named.
String credentialTypeLabel(CredentialType type, AppLocalizations l10n) =>
    switch (type) {
      CredentialType.password => l10n.typePassword,
      CredentialType.apiKey => l10n.typeApiKey,
      CredentialType.secureNote => l10n.typeSelNote,
      CredentialType.totp => l10n.typeSelTotp,
      CredentialType.passkey => l10n.typeSelPasskey,
      CredentialType.sshKey => l10n.typeSshKey,
    };

class CredentialCard extends ConsumerWidget {
  const CredentialCard({
    super.key,
    required this.credential,
    this.dense = false,
    this.enableFolderDrag = false,
  });

  final Credential credential;

  /// When true the card renders flat (no own border/radius/background): it is
  /// meant to sit inside a grouped "filas densas" container that draws the
  /// hairline dividers and border. When false it is a standalone rounded card.
  final bool dense;

  /// When true (desktop only) the card is a drag source: long-press to drag it
  /// onto a folder node in the tree to move it. Off by default so it never
  /// clashes with the reorderable vault list.
  final bool enableFolderDrag;

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

    // Reuse the hierarchical picker (tree + create-subfolder) instead of a flat
    // list, so nested folders are reachable. It returns `[folderId]` (or
    // `[null]` for the vault root); `null` means the sheet was dismissed.
    final picked = await showModalBottomSheet<List<String?>>(
      context: context,
      backgroundColor: palette.drawer,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FolderPickerSheet(selectedFolderId: credential.categoryId),
    );
    if (picked == null) return; // dismissed
    final target = picked.first;
    if (target == credential.categoryId) return; // unchanged

    // Plain-column move (no re-encryption, no password-history entry); bumps
    // updatedAt so the change syncs.
    await ref
        .read(credentialsNotifierProvider.notifier)
        .moveToFolder(credential.id, target);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.cardMovedSuccess),
        backgroundColor: palette.success,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  /// Subtitle under the title: prefer the username, else the site host, else
  /// nothing (keeps the row compact for TOTP/notes without a username).
  String? _subtitle() {
    final u = credential.username;
    if (u != null && u.trim().isNotEmpty) return u;
    final w = credential.website;
    if (w != null && w.trim().isNotEmpty) {
      try {
        final host = Uri.parse(w).host;
        if (host.isNotEmpty) return host.replaceFirst(RegExp(r'^www\.'), '');
      } catch (_) {}
      return w;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final icon = _typeIcons[credential.type] ?? Icons.lock_rounded;
    final color = credentialTypeColor(credential.type, palette);

    void openDetail() {
      if (ResponsiveLayout.isDesktop(context)) {
        ref.read(desktopSelectedCredentialIdProvider.notifier).state =
            credential.id;
        ref.read(desktopRightPaneModeProvider.notifier).state =
            RightPaneMode.details;
      } else {
        context.push(
          AppRoutes.credentialDetail.replaceFirst(':id', credential.id),
        );
      }
    }

    // On desktop the card can be dragged onto a folder node to move it; there,
    // long-press starts the drag (options stay available via right-click), so it
    // must not also open the options sheet.
    final useDrag = enableFolderDrag && ResponsiveLayout.isDesktop(context);

    final inkwell = InkWell(
      borderRadius: dense ? null : BorderRadius.circular(16),
      onTap: openDetail,
      onLongPress: useDrag ? null : () => _showOptionsSheet(context, ref),
      onSecondaryTap: () => _showOptionsSheet(context, ref), // desktop right-click
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: dense ? 11 : 14),
        child: _buildRow(context, ref, palette, icon, color),
      ),
    );

    // Swipe-to-delete intentionally removed: deletion is available via the
    // long-press options sheet and the credential detail screen.
    final Widget card = dense
        ? inkwell // group container draws bg/border/dividers
        : Material(
            color: palette.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: palette.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: inkwell,
          );

    if (!useDrag) return card;
    return LongPressDraggable<String>(
      data: credential.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _dragFeedback(context, palette),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: card,
    );
  }

  Widget _dragFeedback(BuildContext context, AppPalette palette) => Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: palette.divider),
            boxShadow: [
              BoxShadow(
                color: palette.scrim.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drive_file_move_rounded,
                  size: 16, color: palette.accent),
              const SizedBox(width: 8),
              Text(
                credential.title,
                style: TextStyle(
                    color: palette.textPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    AppPalette palette,
    IconData icon,
    Color color,
  ) {
    final l10n = AppLocalizations.of(context);
    // Only this card's own health entry — a `.select` so a change to another
    // credential's flags never rebuilds this row (perf on large vaults).
    final health = ref
        .watch(credentialHealthProvider.select((m) => m[credential.id]));
    final subtitle = _subtitle();
    final typeLabel = credentialTypeLabel(credential.type, l10n);
    final isTotp = credential.type == CredentialType.totp;

    return Row(
      children: [
        // The avatar already encodes the type via colour+icon; label it for
        // screen readers so the row announces its type + title.
        Semantics(
          label: '$typeLabel: ${credential.title}',
          child: CredentialIcon(
            credential: credential,
            defaultIcon: icon,
            color: color,
            size: dense ? 40 : 44,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      credential.title,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (credential.isFavorite) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: l10n.a11yFavorite,
                      child: Icon(Icons.star_rounded,
                          color: palette.warning, size: 15),
                    ),
                  ],
                  if (credential.isDoubleEncrypted) ...[
                    const SizedBox(width: 5),
                    Tooltip(
                      message: l10n.a11yDoubleEncrypted,
                      child: Icon(Icons.enhanced_encryption_rounded,
                          color: palette.typeSshKey, size: 14),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              // Second line: username/host when present, otherwise a subtle
              // type badge so every row keeps a consistent two-line rhythm and
              // TOTP/notes/SSH (which rarely have a username) still name a type.
              subtitle != null
                  ? Text(
                      subtitle,
                      style:
                          TextStyle(color: palette.textMuted, fontSize: 12.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : TypeBadge(label: typeLabel, color: color),
            ],
          ),
        ),
        if (health != null) ...[
          const SizedBox(width: 8),
          health.contains(CredentialHealth.reused)
              ? StatusChip(
                  label: l10n.healthReused,
                  color: palette.danger,
                  icon: Icons.content_copy_rounded,
                  dense: true,
                )
              : StatusChip(
                  label: l10n.strengthWeak,
                  color: palette.warning,
                  icon: Icons.warning_amber_rounded,
                  dense: true,
                ),
        ],
        if (isTotp)
          _TotpVisualizer(credential: credential)
        else ...[
          const SizedBox(width: 4),
          ExcludeSemantics(
            child: Icon(Icons.chevron_right_rounded,
                color: palette.textDisabled, size: 20),
          ),
        ],
      ],
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
              fontFamily: AppTheme.monoFamily,
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
            tooltip: AppLocalizations.of(context).detailCopyCode,
            onPressed: () => _quickCopy(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
