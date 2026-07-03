import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_palette.dart';
import '../../credentials/application/credentials_provider.dart';
import '../application/folders_provider.dart';
import '../domain/entities/folder.dart';

/// Where a deleted folder's subfolders and credentials are moved to.
enum FolderDeleteChoice { toParent, toVault }

/// Shared folder CRUD flows so mobile ([FolderScreen]/[FolderListView]) and
/// desktop ([DesktopMainLayout]/[FolderTree]) use ONE implementation of each
/// dialog and never orphan data on delete.

/// Prompts for a folder name and creates it under [parentId] (`null` = root).
/// Returns the created [Folder], or `null` if cancelled / empty.
Future<Folder?> promptCreateFolder(
  BuildContext context,
  WidgetRef ref, {
  String? parentId,
}) async {
  final l10n = AppLocalizations.of(context);
  final name = await _promptName(
    context,
    title: parentId == null ? l10n.folderDialogTitle : l10n.folderNewSubfolder,
    label: l10n.folderNameLabel,
    hint: l10n.folderNameHint,
    confirmLabel: l10n.commonCreate,
  );
  if (name == null || name.isEmpty) return null;
  return ref
      .read(foldersNotifierProvider.notifier)
      .createFolder(name: name, parentId: parentId);
}

/// Prompts for a new name and renames [folder].
Future<void> promptRenameFolder(
  BuildContext context,
  WidgetRef ref,
  Folder folder,
) async {
  final l10n = AppLocalizations.of(context);
  final name = await _promptName(
    context,
    title: l10n.folderRenameTitle,
    label: l10n.folderNewNameLabel,
    confirmLabel: l10n.commonSave,
    initial: folder.name,
  );
  if (name != null && name.isNotEmpty) {
    await ref
        .read(foldersNotifierProvider.notifier)
        .renameFolder(folder.id, name);
  }
}

/// Confirms and deletes [folder], re-parenting its subfolders and reassigning
/// its credentials (never deleting them) to the destination the user picks:
/// the parent folder or the vault root. Runs [onDeleted] after a successful
/// delete (e.g. to pop the route or clear the desktop selection).
Future<void> confirmDeleteFolder(
  BuildContext context,
  WidgetRef ref,
  Folder folder, {
  VoidCallback? onDeleted,
}) async {
  final palette = context.palette;
  final l10n = AppLocalizations.of(context);
  final hasParent = folder.parentId != null;
  // Captured up front so the confirmation still shows after [onDeleted] pops the
  // folder route (its own context would be unmounted by then).
  final messenger = ScaffoldMessenger.of(context);

  final choice = await showDialog<FolderDeleteChoice>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: palette.drawer,
      title: Text(l10n.folderDeleteTitle,
          style: TextStyle(color: palette.textPrimary)),
      content: Text(l10n.folderDeleteKeepBody(folder.name),
          style: TextStyle(color: palette.textMuted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        if (hasParent)
          TextButton(
            onPressed: () =>
                Navigator.pop(context, FolderDeleteChoice.toParent),
            child: Text(l10n.folderDeleteMoveToParent),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context, FolderDeleteChoice.toVault),
          child: Text(
            hasParent ? l10n.folderDeleteMoveToVault : l10n.commonDelete,
            style: TextStyle(color: palette.danger),
          ),
        ),
      ],
    ),
  );
  if (choice == null) return;

  final destination =
      choice == FolderDeleteChoice.toParent ? folder.parentId : null;

  // Reassign credentials FIRST (plain-column move, bumps updatedAt so it syncs),
  // then re-parent subfolders and drop the folder row.
  await ref
      .read(credentialsNotifierProvider.notifier)
      .reassignFolder(folder.id, destination);
  await ref
      .read(foldersNotifierProvider.notifier)
      .deleteFolder(folder.id, reparentSubfoldersTo: destination);

  onDeleted?.call();
  messenger.showSnackBar(SnackBar(
    content: Text(l10n.folderDeleted),
    backgroundColor: palette.success,
  ));
}

Future<String?> _promptName(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String? hint,
  String? initial,
}) {
  final palette = context.palette;
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: palette.drawer,
      title: Text(title, style: TextStyle(color: palette.textPrimary)),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        style: TextStyle(color: palette.textPrimary),
        textInputAction: TextInputAction.done,
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ctrl.text.trim()),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
