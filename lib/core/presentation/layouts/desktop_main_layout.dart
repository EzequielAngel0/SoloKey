import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../../theme/app_palette.dart';
import '../../../../theme/app_theme.dart';
import '../../../../features/credentials/application/credentials_provider.dart';
import '../../../../features/credentials/application/vault_view_provider.dart';
import '../../../../features/credentials/domain/entities/credential.dart';
import '../../../../features/credentials/presentation/credential_detail_screen.dart';
import '../../../../features/credentials/presentation/credential_form_screen.dart';
import '../../../../features/credentials/presentation/security_audit_screen.dart';
import '../../../../features/credentials/presentation/widgets/command_palette.dart';
import '../../../../features/credentials/presentation/widgets/credential_card.dart';
import '../../../../features/credentials/presentation/widgets/credential_list_widget.dart';
import '../../../../features/credentials/presentation/widgets/empty_state_widget.dart';
import '../../../../features/folders/application/folders_provider.dart';
import '../../../../features/folders/presentation/widgets/folder_tree.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../features/secure_files/presentation/secure_files_screen.dart';
import '../../../../features/settings/presentation/settings_screen.dart';
import '../../../../features/vault_access/application/vault_state_provider.dart';
import '../../../../features/sync/presentation/pairing_screen.dart';
import 'package:password_manager/l10n/app_localizations.dart';
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
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              CommandPalette.show(context),
          // Ctrl+N: nueva credencial (en la pestaña Boveda).
          const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
            ref.read(desktopSelectedNavigationProvider.notifier).state = 0;
            ref.read(desktopSelectedCredentialIdProvider.notifier).state = null;
            ref.read(desktopRightPaneModeProvider.notifier).state =
                RightPaneMode.create;
          },
          // Ctrl+L: bloquear la boveda.
          const SingleActivator(LogicalKeyboardKey.keyL, control: true): () {
            ref.read(vaultNotifierProvider.notifier).lock();
            context.go(AppRoutes.unlock);
          },
        },
        child: Focus(
          autofocus: true,
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
        ),
      ),
    );
  }

  /// Persists the new manual order after a drag in the desktop credentials list.
  void _onReorder(List<Credential> visible, int oldIndex, int newIndex) {
    // newIndex ya viene ajustado por onReorderItem (no restar 1).
    final ids = visible.map((c) => c.id).toList();
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    ref.read(credentialsNotifierProvider.notifier).reorder(ids);
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
    } else if (tabIndex == 6) {
      return const SecureFilesScreen();
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
    final l10n = AppLocalizations.of(context);
    final credentialsAsync = ref.watch(filteredCredentialsProvider);
    final foldersAsync = ref.watch(foldersNotifierProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        title: Text(
          tabIndex == 0
              ? l10n.navVault
              : tabIndex == 1
                  ? l10n.navFolders
                  : l10n.navFavorites,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (tabIndex == 1)
            IconButton(
              icon: Icon(Icons.create_new_folder_rounded, color: palette.primary),
              tooltip: l10n.desktopNewFolderTooltip,
              onPressed: () => _createRootFolder(context, ref),
            )
          else
            IconButton(
              icon: Icon(Icons.add_rounded, color: palette.primary),
              tooltip: l10n.desktopNewCredentialTooltip,
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
                      hintText: l10n.commonSearch,
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
                      fillColor: palette.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: palette.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: palette.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: palette.primary, width: 1.5),
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
            l10n.commonErrorDetail('$e'),
            style: TextStyle(color: palette.error),
          ),
        ),
        data: (creds) {
          if (tabIndex == 1) {
            // Folders: tree (navigate) on top + credentials of the selected
            // folder below. Clicking a credential opens it in the right pane.
            final folders = foldersAsync.valueOrNull ?? [];
            final selFolderId = ref.watch(desktopSelectedFolderIdProvider);
            final folderCreds = creds
                .where((c) => c.categoryId == selFolderId && !c.isHidden)
                .toList();
            final selFolder = selFolderId == null
                ? null
                : folders.where((f) => f.id == selFolderId).firstOrNull;
            final headerName = selFolder?.name ?? l10n.transferNoFolder;

            return Column(
              children: [
                Expanded(
                  flex: 5,
                  child: FolderTree(
                    folders: folders,
                    selectedId: selFolderId,
                    onSelect: (id) {
                      ref.read(desktopSelectedFolderIdProvider.notifier).state =
                          id;
                      ref
                          .read(desktopSelectedCredentialIdProvider.notifier)
                          .state = null;
                      ref.read(desktopRightPaneModeProvider.notifier).state =
                          RightPaneMode.none;
                    },
                  ),
                ),
                Divider(height: 1, color: palette.divider),
                Expanded(
                  flex: 4,
                  child: folderCreds.isEmpty
                      ? EmptyState(
                          icon: Icons.lock_open_rounded,
                          title: l10n.folderEmptyTitle,
                          subtitle: l10n.folderEmptyDesc,
                          compact: true,
                        )
                      : ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                              child: Text(
                                '$headerName · ${folderCreds.length}',
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            ...folderCreds.map((c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: CredentialCard(credential: c),
                                )),
                          ],
                        ),
                ),
              ],
            );
          }

          // Credentials or Favorites list. La lista principal excluye las
          // ocultas (igual que en movil); las favoritas se mantienen tal cual.
          // El orden sigue el mismo selector que en movil (vaultSortProvider).
          final sort = ref.watch(vaultSortProvider);
          final list = sortCredentials(
            tabIndex == 0
                ? creds.where((c) => !c.isHidden).toList()
                : creds.where((c) => c.isFavorite).toList(),
            sort,
          );

          if (list.isEmpty) {
            return EmptyStateWidget(
              message:
                  tabIndex == 0 ? l10n.desktopNoCredentials : l10n.desktopNoFavorites,
              onAdd: () {
                ref.read(desktopRightPaneModeProvider.notifier).state = RightPaneMode.create;
              },
            );
          }

          // Reorden por drag solo en la lista principal, sin busqueda y con el
          // orden manual (reordenar un orden calculado no aplica).
          final canReorder = tabIndex == 0 &&
              _searchCtrl.text.isEmpty &&
              sort == VaultSort.manual;
          return CredentialListWidget(
            credentials: list,
            reorderMode: canReorder,
            onReorder:
                canReorder ? (o, n) => _onReorder(list, o, n) : null,
          );
        },
      ),
    );
  }

  Widget _buildRightPane(int tabIndex) {
    final l10n = AppLocalizations.of(context);
    // Details/Form pane for Vault, Favorites AND Folders: selecting a credential
    // (incl. one inside a folder) shows its detail here.
    final mode = ref.watch(desktopRightPaneModeProvider);
    final selectedId = ref.watch(desktopSelectedCredentialIdProvider);

    if (mode == RightPaneMode.create) {
      return const CredentialFormScreen();
    }

    if (selectedId == null) {
      return _EmptyStateRightPane(
        icon: Icons.shield_rounded,
        title: l10n.desktopSecureVaultTitle,
        subtitle: l10n.desktopSelectCredentialSub,
      );
    }

    if (mode == RightPaneMode.edit) {
      return CredentialFormScreen(existingId: selectedId);
    }

    // Default: Show Details. Keyed by id so switching credentials rebuilds the
    // subtree from scratch — no revealed secret / decrypted plaintext (or the
    // previous TOTP) leaks across selections.
    return CredentialDetailScreen(
      key: ValueKey(selectedId),
      credentialId: selectedId,
    );
  }

  Future<void> _createRootFolder(BuildContext context, WidgetRef ref) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text(l10n.folderDialogTitle, style: TextStyle(color: palette.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            labelText: l10n.folderNameLabel,
            hintText: l10n.folderNameHint,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(l10n.commonCreate)),
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
    final l10n = AppLocalizations.of(context);
    final selectedIndex = ref.watch(desktopSelectedNavigationProvider);
    final collapsed = ref.watch(desktopSidebarCollapsedProvider);

    final menuItems = [
      _SidebarItemData(icon: Icons.inventory_2_rounded, label: l10n.navVault, index: 0),
      _SidebarItemData(icon: Icons.folder_rounded, label: l10n.navFolders, index: 1),
      _SidebarItemData(icon: Icons.star_rounded, label: l10n.navFavorites, index: 2),
      _SidebarItemData(icon: Icons.shield_rounded, label: l10n.navAudit, index: 3),
      _SidebarItemData(icon: Icons.folder_shared_rounded, label: l10n.navSecureFiles, index: 6),
      _SidebarItemData(icon: Icons.settings_rounded, label: l10n.navSettings, index: 4),
      _SidebarItemData(icon: Icons.sync_rounded, label: l10n.navSync, index: 5),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: collapsed ? 72 : 240,
      color: palette.surface,
      child: Column(
        children: [
          // Sidebar Header: brand + collapse toggle
          Padding(
            padding: EdgeInsets.fromLTRB(collapsed ? 0 : 16, 20, collapsed ? 0 : 8, 12),
            child: Row(
              mainAxisAlignment:
                  collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/logo/solokey_mark.png',
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.shield_rounded, color: palette.primary, size: 20),
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SoloKey',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.menu_open_rounded, color: palette.textMuted, size: 20),
                    tooltip: 'Colapsar',
                    onPressed: () => ref
                        .read(desktopSidebarCollapsedProvider.notifier)
                        .state = true,
                  ),
                ],
              ],
            ),
          ),
          if (collapsed)
            IconButton(
              icon: Icon(Icons.menu_rounded, color: palette.textMuted, size: 20),
              tooltip: 'Expandir',
              onPressed: () => ref
                  .read(desktopSidebarCollapsedProvider.notifier)
                  .state = false,
            ),
          // Global search / command palette (Ctrl+K)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12),
            child: _SidebarSearchButton(collapsed: collapsed),
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
                  collapsed: collapsed,
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
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                ref.read(vaultNotifierProvider.notifier).lock();
                context.go(AppRoutes.unlock);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: 12, horizontal: collapsed ? 0 : 16),
                decoration: BoxDecoration(
                  border: Border.all(color: palette.error.withValues(alpha: 0.25)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, color: palette.error, size: 18),
                    if (!collapsed) ...[
                      const SizedBox(width: 10),
                      Text(
                        l10n.homeLockTooltip,
                        style: TextStyle(
                            color: palette.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
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

/// Sidebar entry that opens the global command palette (Ctrl+K).
class _SidebarSearchButton extends StatelessWidget {
  const _SidebarSearchButton({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: p.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => CommandPalette.show(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 12, vertical: 9),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(Icons.search_rounded, color: p.textMuted, size: 18),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).commonSearch,
                    style: TextStyle(color: p.textMuted, fontSize: 13),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: p.divider),
                  ),
                  child: Text(
                    'Ctrl K',
                    style: TextStyle(
                      color: p.textDisabled,
                      fontSize: 10.5,
                      fontFamily: AppTheme.monoFamily,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
    this.collapsed = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool collapsed;
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
    final collapsed = widget.collapsed;

    final iconColor = isSelected
        ? activeColor
        : _isHovered
            ? palette.textPrimary
            : palette.textMuted;

    final item = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(
              horizontal: collapsed ? 10 : 12, vertical: 4),
          padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.12)
                : _isHovered
                    ? palette.textPrimary.withValues(alpha: 0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: collapsed
              ? Center(child: Icon(widget.icon, color: iconColor, size: 20))
              : Row(
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
                    Icon(widget.icon, color: iconColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? palette.textPrimary
                              : _isHovered
                                  ? palette.textPrimary
                                  : palette.textMuted,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (!collapsed) return item;
    return Tooltip(message: widget.label, child: item);
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
