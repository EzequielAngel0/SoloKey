import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/solo_filter_chip.dart';
import '../../../theme/app_palette.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../vault_access/application/vault_state_provider.dart';
import '../../folders/application/folders_provider.dart';
import '../application/credentials_provider.dart';
import '../domain/entities/credential.dart';
import 'widgets/folder_list_view.dart';
import 'widgets/credential_list_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/security_hub_view.dart';

import '../../../../core/presentation/layouts/desktop_main_layout.dart';
import '../../../../core/presentation/layouts/responsive_layout.dart';

/// Filters available as pill chips on the Vault destination. Favorites is now a
/// filter chip instead of a whole navigation tab.
enum VaultFilter { all, favorites, password, totp, passkey, ssh }

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveLayout(
      mobile: MobileHomeScreen(),
      desktop: DesktopMainLayout(),
    );
  }
}

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  final _searchCtrl = TextEditingController();
  int _currentIndex = 0;
  // When true the Vault destination shows the "Ocultas" set instead of active.
  bool _showHidden = false;
  VaultFilter _filter = VaultFilter.all;

  /// Persists the new manual order after a drag in the Credentials list.
  void _onReorder(List<Credential> visible, int oldIndex, int newIndex) {
    // newIndex ya viene ajustado por onReorderItem (no restar 1).
    final ids = visible.map((c) => c.id).toList();
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    ref.read(credentialsNotifierProvider.notifier).reorder(ids);
  }

  bool _matchesFilter(Credential c) => switch (_filter) {
        VaultFilter.all => true,
        VaultFilter.favorites => c.isFavorite,
        VaultFilter.password => c.type == CredentialType.password,
        VaultFilter.totp => c.type == CredentialType.totp,
        VaultFilter.passkey => c.type == CredentialType.passkey,
        VaultFilter.ssh => c.type == CredentialType.sshKey,
      };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _titleFor(AppLocalizations l10n) => switch (_currentIndex) {
        1 => l10n.navFolders,
        2 => l10n.navSecurity,
        3 => l10n.navSettings,
        _ => l10n.navVault,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: VaultAppBar(
        title: _titleFor(l10n),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: Icon(
                _showHidden
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: _showHidden ? palette.primary : palette.textMuted,
              ),
              tooltip: _showHidden ? l10n.homeShowActive : l10n.homeShowHidden,
              onPressed: () => setState(() => _showHidden = !_showHidden),
            ),
          IconButton(
            icon: Icon(Icons.lock_rounded, color: palette.danger),
            tooltip: l10n.homeLockTooltip,
            onPressed: () {
              HapticFeedback.heavyImpact();
              ref.read(vaultNotifierProvider.notifier).lock();
              context.go(AppRoutes.unlock);
            },
          ),
        ],
      ),
      floatingActionButton: switch (_currentIndex) {
        0 => FloatingActionButton.extended(
            onPressed: () => context.push(AppRoutes.credentialCreate),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.homeFabNew),
          ),
        1 => FloatingActionButton.extended(
            onPressed: () => _createRootFolder(context, ref),
            icon: const Icon(Icons.create_new_folder_rounded),
            label: Text(l10n.homeFabFolder),
          ),
        _ => null,
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2_rounded),
            label: l10n.navVault,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder_rounded),
            label: l10n.navFolders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shield_outlined),
            selectedIcon: const Icon(Icons.shield_rounded),
            label: l10n.navSecurity,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.navSettings,
          ),
        ],
      ),
      body: switch (_currentIndex) {
        2 => const SecurityHubView(),
        3 => const SettingsView(),
        1 => _buildFolders(palette),
        _ => _buildVault(l10n, palette),
      },
    );
  }

  Widget _buildFolders(AppPalette palette) {
    final credentialsAsync = ref.watch(filteredCredentialsProvider);
    final foldersAsync = ref.watch(foldersNotifierProvider);
    return RefreshIndicator(
      color: palette.primary,
      backgroundColor: palette.drawer,
      onRefresh: () async {
        await ref.read(credentialsNotifierProvider.notifier).refresh();
        await ref.read(foldersNotifierProvider.notifier).refresh();
      },
      child: credentialsAsync.isLoading
          ? const ShimmerLoader()
          : FolderListView(
              folders: foldersAsync.valueOrNull ?? [],
              credentials: credentialsAsync.valueOrNull ?? [],
            ),
    );
  }

  Widget _buildVault(AppLocalizations l10n, AppPalette palette) {
    final credentialsAsync = ref.watch(filteredCredentialsProvider);
    final credentials = credentialsAsync.valueOrNull ?? [];
    final filtered = credentials
        .where((c) => _showHidden ? c.isHidden : !c.isHidden)
        .where(_matchesFilter)
        .toList();
    final canReorder = _filter == VaultFilter.all &&
        _searchCtrl.text.isEmpty &&
        !_showHidden;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: _SearchField(
            controller: _searchCtrl,
            hint: l10n.homeSearchHint,
            onChanged: (v) =>
                ref.read(credentialSearchNotifierProvider.notifier).update(v),
            onClear: () {
              _searchCtrl.clear();
              ref.read(credentialSearchNotifierProvider.notifier).update('');
            },
          ),
        ),
        SoloFilterChipBar(
          children: [
            SoloFilterChip(
              label: l10n.filterAll,
              selected: _filter == VaultFilter.all,
              onTap: () => setState(() => _filter = VaultFilter.all),
            ),
            SoloFilterChip(
              label: l10n.navFavorites,
              icon: Icons.star_rounded,
              accent: palette.warning,
              selected: _filter == VaultFilter.favorites,
              onTap: () => setState(() => _filter = VaultFilter.favorites),
            ),
            SoloFilterChip(
              label: l10n.filterPasswords,
              accent: palette.typePassword,
              selected: _filter == VaultFilter.password,
              onTap: () => setState(() => _filter = VaultFilter.password),
            ),
            SoloFilterChip(
              label: l10n.typeSelTotp,
              accent: palette.typeTotp,
              selected: _filter == VaultFilter.totp,
              onTap: () => setState(() => _filter = VaultFilter.totp),
            ),
            SoloFilterChip(
              label: l10n.typeSelPasskey,
              accent: palette.typePasskey,
              selected: _filter == VaultFilter.passkey,
              onTap: () => setState(() => _filter = VaultFilter.passkey),
            ),
            SoloFilterChip(
              label: l10n.typeSshKey,
              accent: palette.typeSshKey,
              selected: _filter == VaultFilter.ssh,
              onTap: () => setState(() => _filter = VaultFilter.ssh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            color: palette.primary,
            backgroundColor: palette.drawer,
            onRefresh: () async {
              await ref.read(credentialsNotifierProvider.notifier).refresh();
              await ref.read(foldersNotifierProvider.notifier).refresh();
            },
            child: credentialsAsync.isLoading
                ? const ShimmerLoader()
                : credentialsAsync.hasError
                    ? Center(
                        child: Text(
                          l10n.homeLoadError('${credentialsAsync.error}'),
                          style: TextStyle(color: palette.danger),
                        ),
                      )
                    : filtered.isEmpty
                        ? (_showHidden
                            ? Center(
                                child: Text(
                                  l10n.homeNoHidden,
                                  style: TextStyle(color: palette.textMuted),
                                ),
                              )
                            : EmptyStateWidget(
                                message: l10n.homeEmptyVault,
                                onAdd: () =>
                                    context.push(AppRoutes.credentialCreate),
                              ))
                        : CredentialListWidget(
                            credentials: filtered,
                            onReorder: canReorder
                                ? (o, n) => _onReorder(filtered, o, n)
                                : null,
                          ),
          ),
        ),
      ],
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
        title: Text(l10n.folderDialogTitle,
            style: TextStyle(color: palette.textPrimary)),
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: Text(l10n.commonCreate)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(foldersNotifierProvider.notifier).createFolder(name: name, parentId: null);
    }
  }
}

/// Persistent pill-shaped search field for the Vault destination.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: p.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        prefixIcon: Icon(Icons.search_rounded, color: p.textMuted),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: p.textMuted),
                  onPressed: onClear,
                ),
        ),
        filled: true,
        fillColor: p.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: p.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: p.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
      ),
    );
  }
}
