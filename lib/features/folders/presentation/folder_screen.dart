import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../credentials/application/credentials_provider.dart';
import '../../credentials/presentation/widgets/credential_card.dart';
import '../../../theme/app_palette.dart';
import '../application/folders_provider.dart';
import '../domain/entities/folder.dart';

class FolderScreen extends ConsumerWidget {
  const FolderScreen({super.key, required this.folderId});
  final String folderId;

  Color _hexToColor(BuildContext context, String hex) {
    try {
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return context.palette.accent;
    }
  }

  Future<void> _createSubfolder(BuildContext context, WidgetRef ref) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.folderNewSubfolder, style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            labelText: l10n.folderNameLabel,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(l10n.commonCreate)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(foldersNotifierProvider.notifier).createFolder(name: name, parentId: folderId);
    }
  }

  Future<void> _deleteFolder(BuildContext context, WidgetRef ref, Folder folder) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.folderDeleteTitle, style: TextStyle(color: palette.textPrimary)),
        content: Text(
          l10n.folderDeleteBodyOrphan(folder.name),
          style: TextStyle(color: palette.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete, style: TextStyle(color: palette.danger)),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.folderDeleted),
          backgroundColor: palette.success,
        ));
      }
    }
  }

  void _showFolderOptionsSheet(BuildContext context, WidgetRef ref, Folder subFolder) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.drawer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(subFolder.name, style: TextStyle(color: palette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(subFolder.isFavorite ? Icons.star_border_rounded : Icons.star_rounded, color: palette.warning),
            title: Text(subFolder.isFavorite ? l10n.detailRemoveFavorite : l10n.detailAddFavorite, style: TextStyle(color: palette.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              ref.read(foldersNotifierProvider.notifier).toggleFavorite(subFolder.id);
            },
          ),
          ListTile(
            leading: Icon(Icons.drive_file_rename_outline_rounded, color: palette.textPrimary),
            title: Text(l10n.folderRename, style: TextStyle(color: palette.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              _renameFolder(context, ref, subFolder);
            },
          ),
          Divider(color: palette.divider),
          ListTile(
            leading: Icon(Icons.delete_rounded, color: palette.danger),
            title: Text(l10n.commonDelete, style: TextStyle(color: palette.danger)),
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
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: folder.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.folderRenameTitle, style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(labelText: l10n.folderNewNameLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      ref.read(foldersNotifierProvider.notifier).renameFolder(folder.id, name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final foldersAsync = ref.watch(foldersNotifierProvider);
    final credentialsAsync = ref.watch(filteredCredentialsProvider);

    final folders = foldersAsync.valueOrNull ?? [];
    final currentFolder = folders.where((f) => f.id == folderId).firstOrNull;

    if (currentFolder == null) {
      return Scaffold(
        appBar: VaultAppBar(title: l10n.commonLoading),
        body: Center(child: CircularProgressIndicator(color: palette.accent)),
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
              color: palette.warning,
            ),
            tooltip: currentFolder.isFavorite ? l10n.detailRemoveFavorite : l10n.detailAddFavorite,
            onPressed: () => ref.read(foldersNotifierProvider.notifier).toggleFavorite(currentFolder.id),
          ),
          IconButton(
            icon: Icon(Icons.create_new_folder_outlined, color: palette.textPrimary),
            tooltip: l10n.folderCreateSubfolder,
            onPressed: () => _createSubfolder(context, ref),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: palette.danger),
            tooltip: l10n.folderDeleteTitle,
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
        backgroundColor: palette.accent,
        child: Icon(Icons.add_rounded, color: palette.onPrimary),
      ),
      body: RefreshIndicator(
        color: palette.accent,
        backgroundColor: palette.drawer,
        onRefresh: () async {
          await ref.read(credentialsNotifierProvider.notifier).refresh();
        },
        child: (subFolders.isEmpty && subCredentials.isEmpty)
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.folder_open_rounded, size: 72, color: palette.divider),
                        const SizedBox(height: 20),
                        Text(l10n.folderEmptyTitle, style: TextStyle(color: palette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(l10n.folderEmptyDesc, style: TextStyle(color: palette.textMuted, fontSize: 14)),
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
                          tileColor: palette.card,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: Icon(
                            f.isFavorite ? Icons.folder_special_rounded : Icons.folder_rounded,
                            color: _hexToColor(context, f.colorHex)
                          ),
                          title: Text(f.name, style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w500)),
                          trailing: Icon(Icons.chevron_right_rounded, color: palette.textDisabled),
                        ),
                      )),
                  if (subFolders.isNotEmpty && subCredentials.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: palette.divider),
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
