import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../credentials/application/credentials_provider.dart';
import '../../credentials/presentation/widgets/credential_card.dart';
import '../application/folders_provider.dart';
import '../domain/entities/folder.dart';

class FolderScreen extends ConsumerWidget {
  const FolderScreen({super.key, required this.folderId});
  final String folderId;

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  Future<void> _createSubfolder(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Nueva subcarpeta', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre de la carpeta',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Crear')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(foldersNotifierProvider.notifier).createFolder(name: name, parentId: folderId);
    }
  }

  Future<void> _deleteFolder(BuildContext context, WidgetRef ref, Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Eliminar carpeta', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "${folder.name}"? Sus credenciales quedarán huérfanas o movidas a la raíz.',
          style: const TextStyle(color: Color(0xFF9E9EBF)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFCF6679))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(foldersNotifierProvider.notifier).deleteFolder(folder.id);
      if (context.mounted) {
        if (ResponsiveLayout.isDesktop(context)) {
          ref.read(desktopSelectedFolderIdProvider.notifier).state = null;
        } else {
          context.pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Carpeta eliminada'),
          backgroundColor: Color(0xFF4CAF50),
        ));
      }
    }
  }

  void _showFolderOptionsSheet(BuildContext context, WidgetRef ref, Folder subFolder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(subFolder.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(subFolder.isFavorite ? Icons.star_border_rounded : Icons.star_rounded, color: const Color(0xFFFFB74D)),
            title: Text(subFolder.isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritas', style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              ref.read(foldersNotifierProvider.notifier).toggleFavorite(subFolder.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline_rounded, color: Colors.white),
            title: const Text('Renombrar', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _renameFolder(context, ref, subFolder);
            },
          ),
          const Divider(color: Color(0xFF2A2A4A)),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Color(0xFFCF6679)),
            title: const Text('Eliminar', style: TextStyle(color: Color(0xFFCF6679))),
            onTap: () async {
              Navigator.pop(context);
              _deleteFolder(context, ref, subFolder);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersNotifierProvider);
    final credentialsAsync = ref.watch(filteredCredentialsProvider);

    final folders = foldersAsync.valueOrNull ?? [];
    final currentFolder = folders.where((f) => f.id == folderId).firstOrNull;

    if (currentFolder == null) {
      return const Scaffold(
        appBar: VaultAppBar(title: 'Cargando...'),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
      );
    }

    final subFolders = folders.where((f) => f.parentId == folderId).toList();
    final subCredentials = credentialsAsync.valueOrNull?.where((c) => c.categoryId == folderId).toList() ?? [];

    return Scaffold(
      appBar: VaultAppBar(
        title: currentFolder.name,
        leading: ResponsiveLayout.isDesktop(context) ? const SizedBox.shrink() : null,
        actions: [
          IconButton(
            icon: Icon(
              currentFolder.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xFFFFB74D),
            ),
            tooltip: currentFolder.isFavorite ? 'Quitar de favoritas' : 'Añadir a favoritas',
            onPressed: () => ref.read(foldersNotifierProvider.notifier).toggleFavorite(currentFolder.id),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, color: Colors.white),
            tooltip: 'Crear subcarpeta',
            onPressed: () => _createSubfolder(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFCF6679)),
            tooltip: 'Eliminar carpeta',
            onPressed: () => _deleteFolder(context, ref, currentFolder),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (ResponsiveLayout.isDesktop(context)) {
            ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.create;
          } else {
            context.push(AppRoutes.credentialCreate);
          }
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF6C63FF),
        backgroundColor: const Color(0xFF1A1A2E),
        onRefresh: () async {
          await ref.read(credentialsNotifierProvider.notifier).refresh();
        },
        child: (subFolders.isEmpty && subCredentials.isEmpty)
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.folder_open_rounded, size: 72, color: Color(0xFF2A2A4A)),
                        SizedBox(height: 20),
                        Text('Carpeta Vacía', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('No hay subcarpetas ni credenciales aquí.', style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  ...subFolders.map((f) => Padding(
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
                          tileColor: const Color(0xFF16213E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: Icon(
                            f.isFavorite ? Icons.folder_special_rounded : Icons.folder_rounded, 
                            color: _hexToColor(f.colorHex)
                          ),
                          title: Text(f.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF5C5C7A)),
                        ),
                      )),
                  if (subFolders.isNotEmpty && subCredentials.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFF2A2A4A)),
                    ),
                  ...subCredentials.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CredentialCard(credential: c),
                      )),
                ],
              ),
      ),
    );
  }
}
