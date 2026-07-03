import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/extensions/color_extensions.dart';
import '../../../theme/app_palette.dart';
import '../../credentials/application/credentials_provider.dart';
import '../application/folders_provider.dart';
import '../domain/entities/folder.dart';

/// Curated folder colors. These are folder *data* (persisted as hex on the model
/// and rendered on the tree/cards/picker), not app chrome — so a fixed hex
/// palette is their right home, not a theme token.
const List<String> kFolderColors = [
  '#6C63FF', // indigo (default)
  '#3B82F6', // blue
  '#06B6D4', // cyan
  '#10B981', // emerald
  '#84CC16', // lime
  '#F59E0B', // amber
  '#EF4444', // red
  '#EC4899', // pink
  '#8B5CF6', // violet
  '#64748B', // slate
];

/// Where a deleted folder's subfolders and credentials are moved to.
enum FolderDeleteChoice { toParent, toVault }

/// Shared folder CRUD flows so mobile ([FolderScreen]/[FolderListView]) and
/// desktop ([DesktopMainLayout]/[FolderTree]) use ONE implementation of each
/// dialog and never orphan data on delete.

/// Prompts for a folder name + color and creates it under [parentId]
/// (`null` = root). Returns the created [Folder], or `null` if cancelled/empty.
Future<Folder?> promptCreateFolder(
  BuildContext context,
  WidgetRef ref, {
  String? parentId,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await _promptFolder(
    context,
    title: parentId == null ? l10n.folderDialogTitle : l10n.folderNewSubfolder,
    confirmLabel: l10n.commonCreate,
    initialColor: kFolderColors.first,
  );
  if (result == null || result.name.isEmpty) return null;
  return ref.read(foldersNotifierProvider.notifier).createFolder(
        name: result.name,
        parentId: parentId,
        colorHex: result.colorHex,
      );
}

/// Opens the folder editor (name + color) pre-filled from [folder] and saves the
/// changes. Kept named "rename" for its call sites, but now edits the color too.
Future<void> promptRenameFolder(
  BuildContext context,
  WidgetRef ref,
  Folder folder,
) async {
  final l10n = AppLocalizations.of(context);
  final result = await _promptFolder(
    context,
    title: l10n.folderEditTitle,
    confirmLabel: l10n.commonSave,
    initialName: folder.name,
    initialColor: folder.colorHex,
  );
  if (result != null && result.name.isNotEmpty) {
    await ref.read(foldersNotifierProvider.notifier).updateFolder(
          folder.copyWith(name: result.name, colorHex: result.colorHex),
        );
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

Future<({String name, String colorHex})?> _promptFolder(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialName = '',
  String initialColor = '#6C63FF',
}) {
  return showDialog<({String name, String colorHex})>(
    context: context,
    builder: (_) => _FolderEditorDialog(
      title: title,
      confirmLabel: confirmLabel,
      initialName: initialName,
      initialColor: initialColor,
    ),
  );
}

/// Name + color editor shared by folder create and edit.
class _FolderEditorDialog extends StatefulWidget {
  const _FolderEditorDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.initialColor,
  });

  final String title;
  final String confirmLabel;
  final String initialName;
  final String initialColor;

  @override
  State<_FolderEditorDialog> createState() => _FolderEditorDialogState();
}

class _FolderEditorDialogState extends State<_FolderEditorDialog> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialName);
  late String _color = widget.initialColor;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() =>
      Navigator.pop(context, (name: _ctrl.text.trim(), colorHex: _color));

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    // Keep a non-preset current color selectable too.
    final colors =
        kFolderColors.contains(_color) ? kFolderColors : [_color, ...kFolderColors];

    return AlertDialog(
      backgroundColor: palette.drawer,
      title: Text(widget.title, style: TextStyle(color: palette.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: TextStyle(color: palette.textPrimary),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l10n.folderNameLabel,
              hintText: l10n.folderNameHint,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.folderColorTitle.toUpperCase(),
            style: TextStyle(
              color: palette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [for (final hex in colors) _swatch(hex, palette)],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        TextButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }

  Widget _swatch(String hex, AppPalette palette) {
    final selected = _color == hex;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        key: ValueKey('folder-color-$hex'),
        onTap: () => setState(() => _color = hex),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: hex.toColor(),
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? palette.textPrimary : palette.divider,
              width: selected ? 2.5 : 1,
            ),
          ),
          // White check reads on any swatch color (justified Colors.white use).
          child: selected
              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
