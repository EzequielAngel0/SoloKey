import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
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
