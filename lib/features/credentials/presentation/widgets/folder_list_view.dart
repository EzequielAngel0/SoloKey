import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';
import '../../../../shared/extensions/color_extensions.dart';
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
                const Icon(Icons.folder_open_rounded, size: 72, color: Color(0xFF2A2A4A)),
                const SizedBox(height: 20),
                const Text('Sin carpetas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Organiza tus credenciales', style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 14)),
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
              icon: const Icon(Icons.create_new_folder_rounded, color: Color(0xFF6C63FF)),
              label: const Text('Nueva carpeta raíz', style: TextStyle(color: Color(0xFF6C63FF))),
            ),
          ),
        ),
        ...rootFolders.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => context.push(AppRoutes.folderDetail.replaceFirst(':id', f.id)),
                onLongPress: () => _showFolderOptionsSheet(context, ref, f),
                tileColor: const Color(0xFF16213E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(
                  f.isFavorite ? Icons.folder_special_rounded : Icons.folder_rounded, 
                  color: f.colorHex.toColor()
                ),
                title: Text(f.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF5C5C7A)),
              ),
            )),
        if (noFolderCreds.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Sin carpeta asignada', style: TextStyle(color: Color(0xFF5C5C7A), fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ...noFolderCreds.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CredentialCard(credential: c),
            )),
      ],
    );
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref, String? parentId) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Carpeta', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Eliminar carpeta', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${folder.name}"? Sus subcarpetas o credenciales quedarán liberadas.',
          style: const TextStyle(color: Color(0xFF9E9EBF)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Color(0xFFCF6679)))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(foldersNotifierProvider.notifier).deleteFolder(folder.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Carpeta eliminada'),
          backgroundColor: Color(0xFF4CAF50),
        ));
      }
    }
  }

  Future<void> _renameFolder(BuildContext context, WidgetRef ref, Folder folder) async {
    final ctrl = TextEditingController(text: folder.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Renombrar carpeta', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
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
