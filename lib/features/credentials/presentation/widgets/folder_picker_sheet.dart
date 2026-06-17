import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_palette.dart';
import '../../../../shared/extensions/color_extensions.dart';
import '../../../folders/application/folders_provider.dart';
import '../../../folders/domain/entities/folder.dart';

class FolderPickerSheet extends ConsumerWidget {
  const FolderPickerSheet({
    super.key,
    this.selectedFolderId,
  });

  final String? selectedFolderId;

  Future<void> _createNewFolder(BuildContext context, WidgetRef ref, String? parentId) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.folderNew, style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(labelText: l10n.folderNameLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(l10n.commonCreate)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final newFolder = await ref.read(foldersNotifierProvider.notifier).createFolder(name: name, parentId: parentId);
      if (context.mounted) Navigator.pop(context, <String?>[newFolder.id]);
    }
  }

  Widget _buildNode(BuildContext context, WidgetRef ref, List<Folder> all, Folder f, int depth) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
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
                    color: isSelected ? palette.accent : palette.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle_rounded, color: palette.accent, size: 16),
              ]
            ],
          ),
        ),
        childrenPadding: EdgeInsets.zero,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.create_new_folder_outlined, color: palette.textMuted),
              onPressed: () => _createNewFolder(context, ref, f.id),
              tooltip: l10n.folderAddSubfolder,
            ),
            if (sub.isNotEmpty)
              Icon(Icons.expand_more, color: palette.textDisabled)
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
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
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
                Text(l10n.folderSelectTitle, style: TextStyle(color: palette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _createNewFolder(context, ref, null),
                  icon: Icon(Icons.create_new_folder_rounded, color: palette.accent),
                  label: Text(l10n.folderNewRootShort, style: TextStyle(color: palette.accent)),
                ),
              ],
            ),
          ),
          Divider(color: palette.divider),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.inventory_2_outlined, color: palette.textMuted),
                  title: Text(
                    l10n.folderNoneMainVault,
                    style: TextStyle(
                      color: selectedFolderId == null ? palette.accent : palette.textPrimary,
                      fontWeight: selectedFolderId == null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: selectedFolderId == null ? Icon(Icons.check_circle_rounded, color: palette.accent) : null,
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
