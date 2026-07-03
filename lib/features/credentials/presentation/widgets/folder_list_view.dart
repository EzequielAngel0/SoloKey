import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../../core/presentation/layouts/responsive_layout.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/app_router.dart';
import '../../../../shared/extensions/color_extensions.dart';
import '../../../../theme/app_palette.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../folders/domain/entities/folder.dart';
import '../../../folders/presentation/folder_actions.dart';
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
      onRename: () => promptRenameFolder(context, ref, folder),
      onDelete: () => confirmDeleteFolder(context, ref, folder),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final rootFolders = folders.where((f) => f.parentId == null).toList();
    final noFolderCreds = credentials.where((c) => c.categoryId == null).toList();
    int itemsIn(String id) =>
        credentials.where((c) => c.categoryId == id && !c.isHidden).length;

    if (rootFolders.isEmpty && noFolderCreds.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          EmptyState(
            icon: Icons.folder_open_rounded,
            title: l10n.folderNoFolders,
            subtitle: l10n.folderOrganize,
            action: OutlinedButton.icon(
              onPressed: () => promptCreateFolder(context, ref),
              icon: const Icon(Icons.create_new_folder_rounded),
              label: Text(l10n.folderCreateRoot),
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
              onPressed: () => promptCreateFolder(context, ref),
              icon: Icon(Icons.create_new_folder_rounded, color: palette.accent),
              label: Text(l10n.folderNewRoot, style: TextStyle(color: palette.accent)),
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
                subtitle: Text(
                  l10n.folderItemCount(itemsIn(f.id)),
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: palette.textDisabled),
              ),
            )),
        if (noFolderCreds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l10n.folderUnassigned, style: TextStyle(color: palette.textDisabled, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ...noFolderCreds.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CredentialCard(credential: c),
            )),
      ],
    );
  }
}
