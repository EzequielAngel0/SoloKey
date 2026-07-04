import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/vault_export_service.dart' show kNoFolderFilterId;
import '../../../core/utils/auth_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/relative_time.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';
import '../../folders/application/folders_provider.dart';
import '../application/secure_file_import.dart';
import '../application/secure_files_provider.dart';
import '../domain/entities/secure_file.dart';

/// Standalone "Secure files" vault section. Stores arbitrary files (SSH keys,
/// credentials.json, certs…) encrypted-at-rest on disk. Supports rename, folder
/// organisation, favourites, export and drag-and-drop from the file explorer.
class SecureFilesScreen extends ConsumerStatefulWidget {
  const SecureFilesScreen({super.key});

  @override
  ConsumerState<SecureFilesScreen> createState() => _SecureFilesScreenState();
}

class _SecureFilesScreenState extends ConsumerState<SecureFilesScreen> {
  bool _busy = false;
  bool _dragging = false;

  /// (done, total) while a batch is being encrypted, or null when idle.
  ({int done, int total})? _progress;

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

  Future<void> _addFromPicker() async {
    final picked =
        await FilePicker.platform.pickFiles(withData: true, allowMultiple: true);
    if (picked == null || picked.files.isEmpty || !mounted) return;
    await _addAll([
      for (final f in picked.files)
        if (f.bytes != null) (name: f.name, bytes: f.bytes!),
    ]);
  }

  Future<void> _addAll(List<({String name, Uint8List bytes})> files) async {
    if (files.isEmpty) return;
    final l10n = AppLocalizations.of(context);

    // Enforce the per-file size cap up-front so a huge drop can't OOM us.
    final tooLarge = <String>[];
    final accepted = <({String name, Uint8List bytes})>[];
    for (final f in files) {
      if (isWithinSecureFileLimit(f.bytes.length)) {
        accepted.add(f);
      } else {
        tooLarge.add(f.name);
      }
    }

    if (accepted.isEmpty) {
      _snack(
        tooLarge.length == 1
            ? l10n.secureFilesTooLarge(
                tooLarge.first, formatFileSize(kMaxSecureFileBytes))
            : l10n.secureFilesSkippedLarge(tooLarge.length),
        error: true,
      );
      return;
    }

    // Names already in the store — used to avoid silent duplicates on import.
    final existing = <String>{
      for (final f in ref.read(secureFilesNotifierProvider).valueOrNull ?? [])
        f.name,
    };

    setState(() {
      _busy = true;
      _progress = (done: 0, total: accepted.length);
    });
    var ok = 0;
    String? lastName;
    try {
      final notifier = ref.read(secureFilesNotifierProvider.notifier);
      for (final f in accepted) {
        final name = uniqueSecureFileName(f.name, existing);
        existing.add(name);
        await notifier.addFile(name: name, bytes: f.bytes);
        lastName = name;
        ok++;
        if (mounted) setState(() => _progress = (done: ok, total: accepted.length));
      }
      _snack(ok == 1
          ? l10n.secureFilesAddedSummary(lastName ?? accepted.first.name)
          : l10n.secureFilesAddedCount(ok));
      if (tooLarge.isNotEmpty && mounted) {
        _snack(l10n.secureFilesSkippedLarge(tooLarge.length), error: true);
      }
    } catch (e) {
      if (mounted) _snack(l10n.secureFilesAddError('$e'), error: true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _onDrop(DropDoneDetails detail) async {
    final files = <({String name, Uint8List bytes})>[];
    for (final x in detail.files) {
      try {
        files.add((name: x.name, bytes: await x.readAsBytes()));
      } catch (_) {
        // Skip unreadable items (e.g. dropped folders).
      }
    }
    if (mounted) await _addAll(files);
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

  Future<void> _renameFile(SecureFile file) async {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final ctrl = TextEditingController(text: file.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.secureFilesRenameTitle,
            style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(labelText: l10n.folderNewNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(l10n.secureFilesRename),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == file.name || !mounted) {
      return;
    }
    await ref.read(secureFilesNotifierProvider.notifier).rename(file, newName);
  }

  Future<void> _moveFile(SecureFile file) async {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final folders = ref.read(foldersNotifierProvider).valueOrNull ?? [];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: palette.drawer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.secureFilesMoveTitle,
                  style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: Icon(Icons.folder_off_rounded, color: palette.textMuted),
                    title: Text(l10n.transferNoFolder,
                        style: TextStyle(color: palette.textPrimary)),
                    trailing: file.folderId == null
                        ? Icon(Icons.check_rounded, color: palette.accent)
                        : null,
                    onTap: () => Navigator.pop(context, kNoFolderFilterId),
                  ),
                  for (final f in folders)
                    ListTile(
                      leading: Icon(Icons.folder_rounded, color: palette.accent),
                      title: Text(f.name,
                          style: TextStyle(color: palette.textPrimary)),
                      trailing: file.folderId == f.id
                          ? Icon(Icons.check_rounded, color: palette.accent)
                          : null,
                      onTap: () => Navigator.pop(context, f.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final newFolderId = picked == kNoFolderFilterId ? null : picked;
    await ref
        .read(secureFilesNotifierProvider.notifier)
        .moveToFolder(file, newFolderId);
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

  void _showOptions(SecureFile file) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.drawer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                file.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: palette.warning,
              ),
              title: Text(l10n.secureFilesFavorite,
                  style: TextStyle(color: palette.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(secureFilesNotifierProvider.notifier)
                    .toggleFavorite(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.drive_file_rename_outline_rounded,
                  color: palette.textPrimary),
              title: Text(l10n.secureFilesRename,
                  style: TextStyle(color: palette.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _renameFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.folder_rounded, color: palette.accent),
              title: Text(l10n.secureFilesMove,
                  style: TextStyle(color: palette.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _moveFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.download_rounded, color: palette.textPrimary),
              title: Text(l10n.secureFilesExport,
                  style: TextStyle(color: palette.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _exportFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: palette.danger),
              title: Text(l10n.secureFilesDelete,
                  style: TextStyle(color: palette.danger)),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final filesAsync = ref.watch(secureFilesNotifierProvider);
    final folders = ref.watch(foldersNotifierProvider).valueOrNull ?? [];
    final folderNames = {for (final f in folders) f.id: f.name};

    return Scaffold(
      appBar: VaultAppBar(title: l10n.secureFilesTitle),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _addFromPicker,
        backgroundColor: palette.accent,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.secureFilesAdd),
      ),
      body: DropTarget(
        onDragDone: _onDrop,
        onDragEntered: (_) => setState(() => _dragging = true),
        onDragExited: (_) => setState(() => _dragging = false),
        child: Stack(
          children: [
            filesAsync.when(
              loading: () =>
                  Center(child: CircularProgressIndicator(color: palette.accent)),
              error: (e, _) =>
                  Center(child: Text('$e', style: TextStyle(color: palette.danger))),
              data: (files) {
                if (files.isEmpty) {
                  return EmptyState(
                    icon: Icons.folder_shared_rounded,
                    title: l10n.secureFilesEmptyTitle,
                    subtitle: l10n.secureFilesEmptyDesc,
                  );
                }
                final sorted = [...files]..sort((a, b) {
                    if (a.isFavorite != b.isFavorite) {
                      return a.isFavorite ? -1 : 1;
                    }
                    return b.createdAt.compareTo(a.createdAt);
                  });
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _SecureFileTile(
                    file: sorted[i],
                    folderName: sorted[i].folderId == null
                        ? null
                        : folderNames[sorted[i].folderId],
                    onTap: () => _showOptions(sorted[i]),
                    onMore: () => _showOptions(sorted[i]),
                    onToggleFavorite: () => ref
                        .read(secureFilesNotifierProvider.notifier)
                        .toggleFavorite(sorted[i]),
                  ),
                );
              },
            ),
            if (_busy)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: palette.accent),
                        if (_progress != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            l10n.secureFilesProcessing(
                                _progress!.done, _progress!.total),
                            style: TextStyle(color: palette.textPrimary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            if (_dragging)
              Positioned.fill(
                child: Container(
                  color: palette.accent.withValues(alpha: 0.12),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_download_rounded,
                            size: 56, color: palette.accent),
                        const SizedBox(height: 12),
                        Text(
                          l10n.secureFilesDropHint,
                          style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SecureFileTile extends StatelessWidget {
  const _SecureFileTile({
    required this.file,
    required this.folderName,
    required this.onTap,
    required this.onMore,
    required this.onToggleFavorite,
  });

  final SecureFile file;
  final String? folderName;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final meta = StringBuffer(formatFileSize(file.sizeBytes))
      ..write('  ·  ')
      ..write(relativeTime(l10n, file.createdAt, locale: locale));
    if (folderName != null) meta.write('  ·  $folderName');
    final typeLabel = file.mimeHint == null
        ? l10n.secureFilesFileGeneric
        : l10n.secureFilesFileTypeLabel(file.mimeHint!.toUpperCase());
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onMore,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Semantics(
                label: typeLabel,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: palette.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_iconFor(file.mimeHint), color: palette.accent),
                ),
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
                      meta.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: palette.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  file.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: file.isFavorite ? palette.warning : palette.textMuted,
                ),
                tooltip: l10n.secureFilesFavorite,
                onPressed: onToggleFavorite,
              ),
              IconButton(
                icon: Icon(Icons.more_vert_rounded, color: palette.textMuted),
                tooltip: l10n.secureFilesOptions,
                onPressed: onMore,
              ),
            ],
          ),
        ),
      ),
    );
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
