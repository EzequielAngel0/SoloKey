import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';
import '../../../../shared/extensions/color_extensions.dart';
import '../../../../theme/app_palette.dart';
import '../../domain/entities/credential.dart';
import '../../../folders/domain/entities/folder.dart';
import 'credential_card.dart';
import 'folder_options_sheet.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({
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
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final favFolders = folders.where((f) => f.isFavorite).toList();
    final favCreds = credentials.where((c) => c.isFavorite).toList();

    if (favFolders.isEmpty && favCreds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_outline_rounded, size: 72, color: palette.textEmpty),
            const SizedBox(height: 20),
            Text(
              'No tienes favoritos',
              style: TextStyle(color: palette.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Marca carpetas o credenciales con una estrella',
              style: TextStyle(color: palette.textMuted, fontSize: 14),
            ),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Carpetas Favoritas',
              style: TextStyle(color: palette.textDisabled, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ...favFolders.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => context.push(AppRoutes.folderDetail.replaceFirst(':id', f.id)),
                onLongPress: () => _showFolderOptionsSheet(context, ref, f),
                tileColor: palette.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(Icons.folder_special_rounded, color: f.colorHex.toColor()),
                title: Text(f.name, style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.star_rounded, color: palette.warning),
              ),
            )),
        if (favCreds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Credenciales Favoritas',
              style: TextStyle(color: palette.textDisabled, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ...favCreds.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CredentialCard(credential: c),
            )),
      ],
    );
  }
}
