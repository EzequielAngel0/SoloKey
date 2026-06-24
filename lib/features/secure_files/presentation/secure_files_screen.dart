import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/auth_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';
import '../application/secure_files_provider.dart';
import '../domain/entities/secure_file.dart';

/// Standalone "Secure files" vault section. Stores arbitrary files (SSH keys,
/// credentials.json, certs…) encrypted-at-rest on disk.
class SecureFilesScreen extends ConsumerStatefulWidget {
  const SecureFilesScreen({super.key});

  @override
  ConsumerState<SecureFilesScreen> createState() => _SecureFilesScreenState();
}

class _SecureFilesScreenState extends ConsumerState<SecureFilesScreen> {
  bool _busy = false;

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    final palette = context.palette;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? palette.danger : palette.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addFile() async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.isEmpty || !mounted) return;
    final f = picked.files.first;
    final bytes = f.bytes;
    if (bytes == null) {
      _snack(l10n.secureFilesAddError('empty'), error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(secureFilesNotifierProvider.notifier)
          .addFile(name: f.name, bytes: bytes);
      _snack(l10n.secureFilesAddedSummary(f.name));
    } catch (e) {
      if (mounted) _snack(l10n.secureFilesAddError('$e'), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportFile(SecureFile file) async {
    final l10n = AppLocalizations.of(context);
    final ok =
        await AuthHelper.requireAuth(context, reason: l10n.secureFilesAuthReason);
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      final bytes =
          await ref.read(secureFileRepositoryProvider).readDecrypted(file.id);
      final path = await FilePicker.platform.saveFile(
        fileName: file.name,
        bytes: bytes,
      );
      // On desktop, saveFile only returns the chosen path — we write the bytes.
      // On mobile/web the bytes are written by the picker itself.
      if (path != null &&
          !kIsWeb &&
          (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        await File(path).writeAsBytes(bytes, flush: true);
      }
      if (mounted && path != null) _snack(l10n.secureFilesSaved);
    } catch (e) {
      if (mounted) _snack(l10n.secureFilesExportError('$e'), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteFile(SecureFile file) async {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final ok =
        await AuthHelper.requireAuth(context, reason: l10n.secureFilesAuthReason);
    if (!ok || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.secureFilesDeleteConfirmTitle,
            style: TextStyle(color: palette.textPrimary)),
        content: Text(l10n.secureFilesDeleteConfirmBody(file.name),
            style: TextStyle(color: palette.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.secureFilesDelete,
                style: TextStyle(color: palette.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(secureFilesNotifierProvider.notifier).deleteFile(file.id);
      _snack(l10n.secureFilesDeleted);
    } catch (e) {
      if (mounted) _snack(l10n.secureFilesExportError('$e'), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final filesAsync = ref.watch(secureFilesNotifierProvider);

    return Scaffold(
      appBar: VaultAppBar(title: l10n.secureFilesTitle),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _addFile,
        backgroundColor: palette.accent,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.secureFilesAdd),
      ),
      body: filesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: palette.accent),
        ),
        error: (e, _) => Center(
          child: Text('$e', style: TextStyle(color: palette.danger)),
        ),
        data: (files) {
          if (files.isEmpty) {
            return _EmptyState(
              title: l10n.secureFilesEmptyTitle,
              desc: l10n.secureFilesEmptyDesc,
            );
          }
          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: files.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _SecureFileTile(
                  file: files[i],
                  onExport: () => _exportFile(files[i]),
                  onDelete: () => _deleteFile(files[i]),
                ),
              ),
              if (_busy)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(color: palette.accent),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SecureFileTile extends StatelessWidget {
  const _SecureFileTile({
    required this.file,
    required this.onExport,
    required this.onDelete,
  });

  final SecureFile file;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onExport,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(file.mimeHint), color: palette.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatSize(file.sizeBytes),
                      style: TextStyle(color: palette.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.download_rounded, color: palette.textMuted),
                tooltip: AppLocalizations.of(context).secureFilesExport,
                onPressed: onExport,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: palette.danger),
                tooltip: AppLocalizations.of(context).secureFilesDelete,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static IconData _iconFor(String? ext) {
    switch (ext) {
      case 'json':
        return Icons.data_object_rounded;
      case 'pem':
      case 'key':
      case 'ppk':
      case 'pub':
        return Icons.vpn_key_rounded;
      case 'txt':
      case 'md':
        return Icons.description_rounded;
      case 'zip':
      case 'tar':
      case 'gz':
        return Icons.folder_zip_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.desc});
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: palette.card,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.folder_shared_rounded,
                  size: 48, color: palette.accent.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: palette.textDisabled, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
