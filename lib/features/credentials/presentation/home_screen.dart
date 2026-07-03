import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/solo_filter_chip.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../vault_access/application/vault_state_provider.dart';
import '../../folders/application/folders_provider.dart';
import '../application/credentials_provider.dart';
import '../application/credential_health_provider.dart';
import '../application/vault_view_provider.dart';
import '../domain/entities/credential.dart';
import 'widgets/folder_list_view.dart';
import 'widgets/credential_list_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/security_hub_view.dart';

import '../../../../core/presentation/layouts/desktop_main_layout.dart';
import '../../../../core/presentation/layouts/responsive_layout.dart';

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
  Timer? _searchDebounce;

  /// Persists the new manual order after a drag in the Credentials list.
  void _onReorder(List<Credential> visible, int oldIndex, int newIndex) {
    // newIndex ya viene ajustado por onReorderItem (no restar 1).
    final ids = visible.map((c) => c.id).toList();
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    ref.read(credentialsNotifierProvider.notifier).reorder(ids);
  }

  /// Debounced search: waits ~250ms after the last keystroke before hitting the
  /// filtering provider, so typing in a large vault doesn't refilter per char.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        ref.read(credentialSearchNotifierProvider.notifier).update(value);
      }
    });
    setState(() {}); // refresh clear-button / empty-state affordances immediately
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchCtrl.clear();
    ref.read(credentialSearchNotifierProvider.notifier).update('');
    setState(() {});
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
          if (_currentIndex == 0) ..._buildVaultActions(l10n, palette),
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

  /// Sort menu + reorder toggle + hidden toggle, shown only on the Vault tab.
  List<Widget> _buildVaultActions(AppLocalizations l10n, AppPalette palette) {
    final sort = ref.watch(vaultSortProvider);
    final filter = ref.watch(vaultFilterProvider);
    final reorderMode = ref.watch(vaultReorderModeProvider);
    final canReorder = sort == VaultSort.manual &&
        filter == VaultFilter.all &&
        _searchCtrl.text.isEmpty &&
        !_showHidden;

    return [
      if (canReorder)
        IconButton(
          icon: Icon(
            reorderMode ? Icons.check_rounded : Icons.swap_vert_rounded,
            color: reorderMode ? palette.primary : palette.textMuted,
          ),
          tooltip: reorderMode ? l10n.homeReorderDone : l10n.homeReorderStart,
          onPressed: () => ref.read(vaultReorderModeProvider.notifier).toggle(),
        ),
      if (!reorderMode) ...[
        PopupMenuButton<VaultSort>(
          icon: Icon(Icons.sort_rounded, color: palette.textMuted),
          tooltip: l10n.homeSortTooltip,
          onSelected: (s) => ref.read(vaultSortProvider.notifier).set(s),
          itemBuilder: (_) => [
            _sortMenuItem(VaultSort.manual, l10n.sortManual, sort),
            _sortMenuItem(VaultSort.titleAsc, l10n.sortTitleAsc, sort),
            _sortMenuItem(VaultSort.updatedDesc, l10n.sortUpdatedDesc, sort),
          ],
        ),
        IconButton(
          icon: Icon(
            _showHidden
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: _showHidden ? palette.primary : palette.textMuted,
          ),
          tooltip: _showHidden ? l10n.homeShowActive : l10n.homeShowHidden,
          onPressed: () {
            ref.read(vaultReorderModeProvider.notifier).set(false);
            setState(() => _showHidden = !_showHidden);
          },
        ),
      ],
    ];
  }

  PopupMenuItem<VaultSort> _sortMenuItem(
      VaultSort value, String label, VaultSort current) {
    final palette = context.palette;
    final selected = value == current;
    return PopupMenuItem<VaultSort>(
      value: value,
      child: Row(
        children: [
          Icon(vaultSortIcon(value),
              size: 18, color: selected ? palette.primary : palette.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: selected ? palette.textPrimary : palette.textBody,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 16),
            Icon(Icons.check_rounded, size: 16, color: palette.primary),
          ],
        ],
      ),
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
    final filter = ref.watch(vaultFilterProvider);
    final sort = ref.watch(vaultSortProvider);
    final reorderModePref = ref.watch(vaultReorderModeProvider);
    final credentials = credentialsAsync.valueOrNull ?? [];

    final filtered = sortCredentials(
      credentials
          .where((c) => _showHidden ? c.isHidden : !c.isHidden)
          .where((c) => matchesVaultFilter(c, filter))
          .toList(),
      sort,
    );

    final canReorder = sort == VaultSort.manual &&
        filter == VaultFilter.all &&
        _searchCtrl.text.isEmpty &&
        !_showHidden;
    final reorderActive = reorderModePref && canReorder;

    void selectFilter(VaultFilter f) {
      ref.read(vaultReorderModeProvider.notifier).set(false);
      ref.read(vaultFilterProvider.notifier).set(f);
    }

    return Column(
      children: [
        _VaultHeader(
          count: filtered.length,
          onOpenSecurity: () => setState(() => _currentIndex = 2),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: _SearchField(
            controller: _searchCtrl,
            hint: l10n.homeSearchHint,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
        ),
        SoloFilterChipBar(
          children: [
            SoloFilterChip(
              label: l10n.filterAll,
              selected: filter == VaultFilter.all,
              onTap: () => selectFilter(VaultFilter.all),
            ),
            SoloFilterChip(
              label: l10n.navFavorites,
              icon: Icons.star_rounded,
              accent: palette.warning,
              selected: filter == VaultFilter.favorites,
              onTap: () => selectFilter(VaultFilter.favorites),
            ),
            SoloFilterChip(
              label: l10n.filterPasswords,
              accent: palette.typePassword,
              selected: filter == VaultFilter.password,
              onTap: () => selectFilter(VaultFilter.password),
            ),
            SoloFilterChip(
              label: l10n.typeSelTotp,
              accent: palette.typeTotp,
              selected: filter == VaultFilter.totp,
              onTap: () => selectFilter(VaultFilter.totp),
            ),
            SoloFilterChip(
              label: l10n.typeSelPasskey,
              accent: palette.typePasskey,
              selected: filter == VaultFilter.passkey,
              onTap: () => selectFilter(VaultFilter.passkey),
            ),
            SoloFilterChip(
              label: l10n.typeSshKey,
              accent: palette.typeSshKey,
              selected: filter == VaultFilter.ssh,
              onTap: () => selectFilter(VaultFilter.ssh),
            ),
          ],
        ),
        if (reorderActive) _ReorderHintBar(label: l10n.homeReorderHint),
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
                        ? _buildEmpty(context, l10n)
                        : CredentialListWidget(
                            credentials: filtered,
                            reorderMode: reorderActive,
                            sectioned: sort == VaultSort.titleAsc,
                            onReorder: canReorder
                                ? (o, n) => _onReorder(filtered, o, n)
                                : null,
                          ),
          ),
        ),
      ],
    );
  }

  /// Distinguishes a truly empty vault (offer "add first") from "no results"
  /// when a search/filter is active or the hidden view is on.
  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    if (_showHidden) {
      return EmptyState(
        icon: Icons.visibility_off_rounded,
        title: l10n.homeNoHidden,
      );
    }
    final filtering = _searchCtrl.text.isNotEmpty ||
        ref.read(vaultFilterProvider) != VaultFilter.all;
    if (filtering) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.commandNoResults,
      );
    }
    return EmptyStateWidget(
      message: l10n.homeEmptyVault,
      onAdd: () => context.push(AppRoutes.credentialCreate),
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

/// Vault dashboard header: a time-of-day greeting with the credential count and
/// a tappable "issues" chip, plus an at-a-glance [ScoreRing] on the right. Both
/// the chip and the ring jump to the Security tab for the full audit.
class _VaultHeader extends ConsumerWidget {
  const _VaultHeader({required this.count, required this.onOpenSecurity});

  final int count;
  final VoidCallback onOpenSecurity;

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGreetingMorning;
    if (h < 19) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final issues = ref.watch(credentialHealthProvider).length;
    final score = ref.watch(vaultHealthScoreProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting(l10n),
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      l10n.homeCredentialCount(count),
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (issues > 0) ...[
                      const SizedBox(width: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(7),
                        onTap: onOpenSecurity,
                        child: StatusChip(
                          label: l10n.homeIssuesChip(issues),
                          color: p.warning,
                          icon: Icons.shield_rounded,
                          dense: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // The ring only makes sense once there is something to score.
          if (count > 0) ...[
            const SizedBox(width: 12),
            Tooltip(
              message: l10n.homeHealthTooltip,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onOpenSecurity,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ScoreRing(score: score, size: 44),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Thin banner shown while the list is in drag-to-reorder mode.
class _ReorderHintBar extends StatelessWidget {
  const _ReorderHintBar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: p.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.rInput),
        border: Border.all(color: p.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_indicator_rounded, size: 16, color: p.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: p.primary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
