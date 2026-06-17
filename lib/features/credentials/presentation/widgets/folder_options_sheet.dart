import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_palette.dart';
import '../../../folders/domain/entities/folder.dart';
import '../../../folders/application/folders_provider.dart';

void showFolderOptionsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Folder folder,
  bool showManagementOptions = false,
  VoidCallback? onRename,
  VoidCallback? onDelete,
}) {
  final palette = context.palette;
  final l10n = AppLocalizations.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: palette.drawer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            folder.name,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            folder.isFavorite ? Icons.star_border_rounded : Icons.star_rounded,
            color: palette.warning,
          ),
          title: Text(
            folder.isFavorite ? l10n.detailRemoveFavorite : l10n.detailAddFavorite,
            style: TextStyle(color: palette.textPrimary),
          ),
          onTap: () {
            Navigator.pop(context);
            ref.read(foldersNotifierProvider.notifier).toggleFavorite(folder.id);
          },
        ),
        if (showManagementOptions) ...[
          ListTile(
            leading: Icon(Icons.drive_file_rename_outline_rounded, color: palette.textPrimary),
            title: Text(l10n.folderRename, style: TextStyle(color: palette.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              if (onRename != null) onRename();
            },
          ),
          Divider(color: palette.divider),
          ListTile(
            leading: Icon(Icons.delete_rounded, color: palette.danger),
            title: Text(l10n.commonDelete, style: TextStyle(color: palette.danger)),
            onTap: () {
              Navigator.pop(context);
              if (onDelete != null) onDelete();
            },
          ),
        ],
        const SizedBox(height: 20),
      ],
    ),
  );
}
