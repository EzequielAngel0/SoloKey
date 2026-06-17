import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../../theme/app_palette.dart';
import '../../../../features/credentials/application/credentials_provider.dart';
import '../../../../features/credentials/presentation/credential_detail_screen.dart';
import '../../../../features/credentials/presentation/credential_form_screen.dart';
import '../../../../features/credentials/presentation/security_audit_screen.dart';
import '../../../../features/credentials/presentation/widgets/credential_card.dart';
import '../../../../features/credentials/presentation/widgets/empty_state_widget.dart';
import '../../../../features/folders/application/folders_provider.dart';
import '../../../../features/folders/presentation/folder_screen.dart';
import '../../../../features/settings/presentation/settings_screen.dart';
import '../../../../features/vault_access/application/vault_state_provider.dart';
import '../../../../features/sync/presentation/pairing_screen.dart';
import 'desktop_layout_state.dart';
import 'auto_lock_manager.dart';

class DesktopMainLayout extends ConsumerStatefulWidget {
  const DesktopMainLayout({super.key});

  @override
  ConsumerState<DesktopMainLayout> createState() => _DesktopMainLayoutState();
}

class _DesktopMainLayoutState extends ConsumerState<DesktopMainLayout> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeTab = ref.watch(desktopSelectedNavigationProvider);

    return AutoLockManager(
      child: Scaffold(
        body: Row(
          children: [
            // Column 1: Sidebar Navigation
            const _DesktopSidebar(),
            // Vertical divider
            Container(
              width: 1,
              color: palette.divider,
            ),
            // Content Area (Middle Column + Right Column)
            Expanded(
              child: _buildContentArea(activeTab),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea(int tabIndex) {
    final palette = context.palette;
    // For tabs that take full width (Security Audit, Settings, Sync/Transfer)
    if (tabIndex == 3) {
      return const SecurityAuditScreen();
    } else if (tabIndex == 4) {
      return const SettingsScreen();
    } else if (tabIndex == 5) {
      return const PairingScreen();
    }

    // Tabs with lists (Credentials, Folders, Favorites)
    return Row(
      children: [
        // Column 2: Middle List Pane
        SizedBox(
          width: 360,
          child: _buildMiddleListPane(tabIndex),
        ),
        // Vertical divider
        Container(
          width: 1,
          color: palette.divider,
        ),
        // Column 3: Right Details/Form Pane
        Expanded(
          child: _buildRightPane(tabIndex),
        ),
      ],
    );
  }

  Widget _buildMiddleListPane(int tabIndex) {
    final palette = context.palette;
    final credentialsAsync = ref.watch(filteredCredentialsProvider);
    final foldersAsync = ref.watch(foldersNotifierProvider);

    return Scaffold(
      backgroundColor: palette.cardDark,
      appBar: AppBar(
        backgroundColor: palette.cardDark,
        title: Text(
          tabIndex == 0
              ? 'Credenciales'
              : tabIndex == 1
                  ? 'Carpetas'
                  : 'Favoritas',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (tabIndex == 1)
            IconButton(
              icon: Icon(Icons.create_new_folder_rounded, color: palette.primary),
              tooltip: 'Nueva carpeta',
              onPressed: () => _createRootFolder(context, ref),
            )
          else
            IconButton(
              icon: Icon(Icons.add_rounded, color: palette.primary),
              tooltip: 'Nueva credencial',
              onPressed: () {
                ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.create;
                ref.read(desktopSelectedCredentialIdProvider.notifier).state = null;
              },
            ),
          const SizedBox(width: 8),
        ],
        bottom: tabIndex == 1
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => ref.read(credentialSearchNotifierProvider.notifier).update(v),
                    style: TextStyle(color: palette.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search_rounded, color: palette.textMuted, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: palette.textMuted, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref.read(credentialSearchNotifierProvider.notifier).update('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: palette.drawer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
      ),
      body: credentialsAsync.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: palette.error),
          ),
        ),
        data: (creds) {
          if (tabIndex == 1) {
            // Folders view
            final folders = foldersAsync.valueOrNull ?? [];
            final rootFolders = folders.where((f) => f.parentId == null).toList();
            final noFolderCreds = creds.where((c) => c.categoryId == null).toList();

            if (rootFolders.isEmpty && noFolderCreds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_rounded, size: 48, color: palette.divider),
                    const SizedBox(height: 12),
                    Text('Bóveda vacía', style: TextStyle(color: palette.textMuted)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _createRootFolder(context, ref),
                      icon: const Icon(Icons.create_new_folder_rounded, size: 16),
                      label: const Text('Crear carpeta'),
                    )
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...rootFolders.map((f) {
                  final activeFolderId = ref.watch(desktopSelectedFolderIdProvider);
                  final isSelected = activeFolderId == f.id;
                  Color folderColor;
                  try {
                    folderColor = Color(int.parse('FF${f.colorHex.replaceFirst('#', '')}', radix: 16));
                  } catch (_) {
                    folderColor = palette.accent;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      onTap: () {
                        ref.read(desktopSelectedFolderIdProvider.notifier).state = f.id;
                        ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.none;
                      },
                      selected: isSelected,
                      selectedTileColor: palette.surface,
                      tileColor: palette.card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      leading: Icon(
                        f.isFavorite ? Icons.folder_special_rounded : Icons.folder_rounded,
                        color: folderColor,
                      ),
                      title: Text(
                        f.name,
                        style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 18),
                    ),
                  );
                }),
                if (noFolderCreds.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Sin carpeta asignada',
                      style: TextStyle(color: palette.textDisabled, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...noFolderCreds.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CredentialCard(credential: c),
                      )),
                ]
              ],
            );
          }

          // Credentials or Favorites list
          final list = tabIndex == 0 ? creds : creds.where((c) => c.isFavorite).toList();

          if (list.isEmpty) {
            return EmptyStateWidget(
              message: tabIndex == 0 ? 'Sin credenciales' : 'Sin favoritas',
              onAdd: () {
                ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.create;
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              return CredentialCard(credential: list[i]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRightPane(int tabIndex) {
    if (tabIndex == 1) {
      // Folder View in Right Column
      final folderId = ref.watch(desktopSelectedFolderIdProvider);
      if (folderId == null) {
        return const _EmptyStateRightPane(
          icon: Icons.folder_rounded,
          title: 'Selecciona una carpeta',
          subtitle: 'Haz clic en una carpeta de la lista para ver su contenido aquí.',
        );
      }
      return FolderScreen(folderId: folderId);
    }

    // Credentials / Favorites Right Pane (Details or Form)
    final mode = ref.watch(desktopRightPaneModeProvider);
    final selectedId = ref.watch(desktopSelectedCredentialIdProvider);

    if (mode == RightPaneMode.create) {
      return const CredentialFormScreen();
    }

    if (selectedId == null) {
      return const _EmptyStateRightPane(
        icon: Icons.shield_rounded,
        title: 'Bóveda Segura',
        subtitle: 'Selecciona una credencial de la lista para ver o editar sus detalles.',
      );
    }

    if (mode == RightPaneMode.edit) {
      return CredentialFormScreen(existingId: selectedId);
    }

    // Default: Show Details
    return CredentialDetailScreen(credentialId: selectedId);
  }

  Future<void> _createRootFolder(BuildContext context, WidgetRef ref) async {
    final palette = context.palette;
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text('Carpeta', style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
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

class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final selectedIndex = ref.watch(desktopSelectedNavigationProvider);

    const menuItems = [
      _SidebarItemData(icon: Icons.lock_rounded, label: 'Credenciales', index: 0),
      _SidebarItemData(icon: Icons.folder_rounded, label: 'Carpetas', index: 1),
      _SidebarItemData(icon: Icons.star_rounded, label: 'Favoritas', index: 2),
      _SidebarItemData(icon: Icons.security_rounded, label: 'Auditoría', index: 3),
      _SidebarItemData(icon: Icons.settings_rounded, label: 'Ajustes', index: 4),
      _SidebarItemData(icon: Icons.sync_rounded, label: 'Sincronizar', index: 5),
    ];

    return Container(
      width: 240,
      color: palette.background,
      child: Column(
        children: [
          // Sidebar Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.vpn_key_rounded,
                    color: palette.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SoloKey',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Secure Vault',
                      style: TextStyle(
                        color: palette.textDisabled,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, i) {
                final item = menuItems[i];
                final isSelected = selectedIndex == item.index;

                return _SidebarItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(desktopSelectedNavigationProvider.notifier).state = item.index;
                    // Reset details state on tab switch
                    ref.read(desktopSelectedCredentialIdProvider.notifier).state = null;
                    ref.read(desktopSelectedFolderIdProvider.notifier).state = null;
                    ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.none;
                  },
                );
              },
            ),
          ),
          // Sidebar Footer with Lock Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                ref.read(vaultNotifierProvider.notifier).lock();
                context.go(AppRoutes.unlock);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: palette.error.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, color: palette.error, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Bloquear Bóveda',
                      style: TextStyle(color: palette.error, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItemData {
  const _SidebarItemData({
    required this.icon,
    required this.label,
    required this.index,
  });

  final IconData icon;
  final String label;
  final int index;
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeColor = palette.primary;
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.08)
                : _isHovered
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: isSelected ? 12 : 16),
              Icon(
                widget.icon,
                color: isSelected
                    ? activeColor
                    : _isHovered
                        ? palette.textPrimary
                        : palette.textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: isSelected
                      ? palette.textPrimary
                      : _isHovered
                          ? palette.textPrimary
                          : palette.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateRightPane extends StatelessWidget {
  const _EmptyStateRightPane({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: palette.card,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: palette.primary.withValues(alpha: 0.8),
              ),
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
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textDisabled,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
