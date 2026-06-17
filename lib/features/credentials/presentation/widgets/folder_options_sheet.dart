import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/extensions/color_extensions.dart';
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
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A2E),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            folder.isFavorite ? Icons.star_border_rounded : Icons.star_rounded,
            color: const Color(0xFFFFB74D),
          ),
          title: Text(
            folder.isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritas',
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            ref.read(foldersNotifierProvider.notifier).toggleFavorite(folder.id);
          },
        ),
        if (showManagementOptions) ...[
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline_rounded, color: Colors.white),
            title: const Text('Renombrar', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              if (onRename != null) onRename();
            },
          ),
          const Divider(color: Color(0xFF2A2A4A)),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Color(0xFFCF6679)),
            title: const Text('Eliminar', style: TextStyle(color: Color(0xFFCF6679))),
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
