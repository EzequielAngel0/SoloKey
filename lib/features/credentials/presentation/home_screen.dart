import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_router.dart';
import '../../../shared/extensions/color_extensions.dart';
import '../../../shared/widgets/staggered_list_item.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../vault_access/application/vault_state_provider.dart';
import '../../folders/application/folders_provider.dart';
import '../../folders/domain/entities/folder.dart';
import '../application/credentials_provider.dart';
import '../domain/entities/credential.dart';
import 'widgets/credential_card.dart';
import 'widgets/folder_options_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final credentialsAsync = ref.watch(filteredCredentialsProvider);
    final foldersAsync = ref.watch(foldersNotifierProvider);

    final credentials = credentialsAsync.valueOrNull ?? [];
    List<Credential> filtered = [];
    
    if (_currentIndex == 0) {
      filtered = credentials;
    } else if (_currentIndex == 2) {
      filtered = credentials.where((c) => c.isFavorite).toList();
    }

    return Scaffold(
      appBar: VaultAppBar(
        title: 'SoloKey',
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_rounded, color: Color(0xFFCF6679)),
            tooltip: 'Bloquear',
            onPressed: () {
              HapticFeedback.heavyImpact();
              ref.read(vaultNotifierProvider.notifier).lock();
              context.go(AppRoutes.unlock);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            color: const Color(0xFF1A1A2E),
            onSelected: (val) {
              if (val == 'audit') context.push(AppRoutes.securityAudit);
              if (val == 'settings') context.push(AppRoutes.settings);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'audit',
                child: Row(
                  children: [
                    Icon(Icons.security_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Auditoría', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Ajustes', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => ref.read(credentialSearchNotifierProvider.notifier).update(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar credenciales…',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9E9EBF)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF9E9EBF)),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(credentialSearchNotifierProvider.notifier).update('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF16213E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 2
          ? null // No FAB on Favorites tab
          : FloatingActionButton.extended(
              onPressed: _currentIndex == 1
                  ? () => _createRootFolder(context, ref)
                  : () => context.push(AppRoutes.credentialCreate),
              backgroundColor: const Color(0xFF6C63FF),
              icon: Icon(
                _currentIndex == 1 ? Icons.create_new_folder_rounded : Icons.add_rounded,
                color: Colors.white,
              ),
              label: Text(
                _currentIndex == 1 ? 'Carpeta' : 'Nueva',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F0E17),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: const Color(0xFF5C5C7A),
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.all_inbox_rounded), label: 'Credenciales'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree_rounded), label: 'Carpetas'),
          BottomNavigationBarItem(icon: Icon(Icons.star_rounded), label: 'Favoritas'),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF6C63FF),
        backgroundColor: const Color(0xFF1A1A2E),
        onRefresh: () async {
          await ref.read(credentialsNotifierProvider.notifier).refresh();
          await ref.read(foldersNotifierProvider.notifier).refresh();
        },
        child: credentialsAsync.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
            : credentialsAsync.hasError
                ? Center(child: Text('Error: ${credentialsAsync.error}', style: const TextStyle(color: Color(0xFFCF6679))))
                : (_currentIndex == 1)
                    ? _FolderListView(folders: foldersAsync.valueOrNull ?? [], credentials: credentials)
                    : (_currentIndex == 2)
                        ? _FavoritesView(folders: foldersAsync.valueOrNull ?? [], credentials: credentials)
                        : filtered.isEmpty
                            ? _EmptyState(
                                message: 'Tu bóveda está vacía',
                                onAdd: () => context.push(AppRoutes.credentialCreate),
                              )
                            : _CredentialList(credentials: filtered),
      ),
    );
  }

  Future<void> _createRootFolder(BuildContext context, WidgetRef ref) async {
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
      await ref.read(foldersNotifierProvider.notifier).createFolder(name: name, parentId: null);
    }
  }
}

class _FavoritesView extends ConsumerWidget {
  const _FavoritesView({required this.folders, required this.credentials});
  final List<Folder> folders;
  final List<Credential> credentials;



  void _showFolderOptionsSheet(BuildContext context, WidgetRef ref, Folder folder) {
    showFolderOptionsSheet(
      context: context,
      ref: ref,
      folder: folder,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favFolders = folders.where((f) => f.isFavorite).toList();
    final favCreds = credentials.where((c) => c.isFavorite).toList();

    if (favFolders.isEmpty && favCreds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_outline_rounded, size: 72, color: Color(0xFF2A2A4A)),
            const SizedBox(height: 20),
            const Text('No tienes favoritos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Marca carpetas o credenciales con una estrella', style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 14)),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (favFolders.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Carpetas Favoritas', style: TextStyle(color: Color(0xFF5C5C7A), fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ...favFolders.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => context.push(AppRoutes.folderDetail.replaceFirst(':id', f.id)),
                onLongPress: () => _showFolderOptionsSheet(context, ref, f),
                tileColor: const Color(0xFF16213E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(Icons.folder_special_rounded, color: f.colorHex.toColor()),
                title: Text(f.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.star_rounded, color: Color(0xFFFFB74D)),
              ),
            )),
        if (favCreds.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Credenciales Favoritas', style: TextStyle(color: Color(0xFF5C5C7A), fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ...favCreds.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CredentialCard(credential: c),
            )),
      ],
    );
  }
}

class _FolderListView extends ConsumerWidget {
  const _FolderListView({required this.folders, required this.credentials});
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

class _CredentialList extends StatelessWidget {
  const _CredentialList({required this.credentials});
  final List<Credential> credentials;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: credentials.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => StaggeredListItem(
        index: i,
        child: CredentialCard(credential: credentials[i]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onAdd});
  final String message;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo/SoloKey.png',
            height: 72,
            width: 72,
            color: const Color(0xFF2A2A4A),
          ),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Añade tu primera credencial', style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 14)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Añadir credencial'),
          ),
        ],
      ),
    );
  }
}
