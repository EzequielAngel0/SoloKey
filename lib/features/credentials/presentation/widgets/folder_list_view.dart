import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../../core/presentation/layouts/responsive_layout.dart';
import '../../../../router/app_router.dart';
import '../../../../shared/extensions/color_extensions.dart';
import '../../../../theme/app_palette.dart';
import '../../../folders/application/folders_provider.dart';
import '../../../folders/domain/entities/folder.dart';
import '../../domain/entities/credential.dart';
import 'credential_card.dart';
import 'folder_options_sheet.dart';

class FolderListView extends ConsumerWidget {
  const FolderListView({
    super.key,
    required this.folders,
    required this.credentials,
  });

  final List<Folder> folders;
  final List<Credential> credentials;

  void _showFolderOptionsSheet(BuildContext context, WidgetRef ref, Folder folder) {
    showFolderOptionsSheet(
      context: context,
      ref: ref,
      folder: folder,
      showManagementOptions: true,
      onRename: () => _renameFolder(context, ref, folder),
      onDelete: () => _deleteFolder(context, ref, folder),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final rootFolders = folders.where((f) => f.parentId == null).toList();
    final noFolderCreds = credentials.where((c) => c.categoryId == null).toList();

    if (rootFolders.isEmpty && noFolderCreds.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open_rounded, size: 72, color: palette.textEmpty),
                const SizedBox(height: 20),
                Text('Sin carpetas', style: TextStyle(color: palette.textPrimary, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Organiza tus credenciales', style: TextStyle(color: palette.textMuted, fontSize: 14)),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _createFolder(context, ref, null),
                  icon: const Icon(Icons.create_new_folder_rounded),
                  label: const Text('Crear carpeta raíz'),
                )
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _createFolder(context, ref, null),
              icon: Icon(Icons.create_new_folder_rounded, color: palette.accent),
              label: Text('Nueva carpeta raíz', style: TextStyle(color: palette.accent)),
            ),
          ),
        ),
        ...rootFolders.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () {
                  if (ResponsiveLayout.isDesktop(context)) {
                    ref.read(desktopSelectedFolderIdProvider.notifier).state = f.id;
                    ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.none;
                  } else {
                    context.push(AppRoutes.folderDetail.replaceFirst(':id', f.id));
                  }
                },
                onLongPress: () => _showFolderOptionsSheet(context, ref, f),
                tileColor: palette.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(
                  f.isFavorite ? Icons.folder_special_rounded : Icons.folder_rounded,
                  color: f.colorHex.toColor(),
                ),
                title: Text(f.name, style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right_rounded, color: palette.textDisabled),
              ),
            )),
        if (noFolderCreds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Sin carpeta asignada', style: TextStyle(color: palette.textDisabled, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ...noFolderCreds.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CredentialCard(credential: c),
            )),
      ],
    );
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref, String? parentId) async {
    final palette = context.palette;
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text('Carpeta', style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Nombre de la carpeta',
            hintText: 'ej. Trabajo, Sociales…',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Crear')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(foldersNotifierProvider.notifier).createFolder(name: name, parentId: parentId);
    }
  }

  Future<void> _deleteFolder(BuildContext context, WidgetRef ref, Folder folder) async {
    final palette = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text('Eliminar carpeta', style: TextStyle(color: palette.textPrimary)),
        content: Text(
          '¿Eliminar "${folder.name}"? Sus subcarpetas o credenciales quedarán liberadas.',
          style: TextStyle(color: palette.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar', style: TextStyle(color: palette.danger))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(foldersNotifierProvider.notifier).deleteFolder(folder.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Carpeta eliminada'),
          backgroundColor: palette.success,
        ));
      }
    }
  }

  Future<void> _renameFolder(BuildContext context, WidgetRef ref, Folder folder) async {
    final palette = context.palette;
    final ctrl = TextEditingController(text: folder.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text('Renombrar carpeta', style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
          decoration: const InputDecoration(labelText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Guardar')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      ref.read(foldersNotifierProvider.notifier).renameFolder(folder.id, name);
    }
  }
}
