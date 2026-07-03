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
import '../../credentials/presentation/widgets/folder_options_sheet.dart';
import '../../../shared/extensions/color_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../theme/app_palette.dart';
import '../application/folders_provider.dart';
import '../domain/entities/folder.dart';
import 'folder_actions.dart';
import 'widgets/folder_breadcrumbs.dart';

class FolderScreen extends ConsumerWidget {
  const FolderScreen({super.key, required this.folderId});
  final String folderId;

  void _onCurrentFolderDeleted(BuildContext context, WidgetRef ref) {
    if (ResponsiveLayout.isDesktop(context)) {
      ref.read(desktopSelectedFolderIdProvider.notifier).state = null;
    } else {
      context.pop();
    }
  }

  void _showFolderOptionsSheet(BuildContext context, WidgetRef ref, Folder subFolder) {
    showFolderOptionsSheet(
      context: context,
      ref: ref,
      folder: subFolder,
      showManagementOptions: true,
      onRename: () => promptRenameFolder(context, ref, subFolder),
      onDelete: () => confirmDeleteFolder(context, ref, subFolder),
    );
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

    final allCredentials = credentialsAsync.valueOrNull ?? const [];
    final subFolders = folders.where((f) => f.parentId == folderId).toList();
    final subCredentials =
        allCredentials.where((c) => c.categoryId == folderId).toList();
    int itemsIn(String id) =>
        allCredentials.where((c) => c.categoryId == id && !c.isHidden).length;

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
            onPressed: () => promptCreateFolder(context, ref, parentId: folderId),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: palette.danger),
            tooltip: l10n.folderDeleteTitle,
            onPressed: () => confirmDeleteFolder(
              context,
              ref,
              currentFolder,
              onDeleted: () => _onCurrentFolderDeleted(context, ref),
            ),
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
      body: Column(
        children: [
          FolderBreadcrumbs(folders: folders, currentId: folderId),
          Expanded(
            child: RefreshIndicator(
              color: palette.accent,
              backgroundColor: palette.drawer,
              onRefresh: () async {
                await ref.read(credentialsNotifierProvider.notifier).refresh();
              },
        child: (subFolders.isEmpty && subCredentials.isEmpty)
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: l10n.folderEmptyTitle,
                    subtitle: l10n.folderEmptyDesc,
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
                            color: f.colorHex.toColor(),
                          ),
                          title: Text(f.name, style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            l10n.folderItemCount(itemsIn(f.id)),
                            style: TextStyle(color: palette.textMuted, fontSize: 12),
                          ),
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
          ),
        ],
      ),
    );
  }
}
