import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../theme/app_palette.dart';
import '../../vault_access/application/vault_state_provider.dart';
import '../../folders/application/folders_provider.dart';
import '../application/credentials_provider.dart';
import '../domain/entities/credential.dart';
import 'widgets/favorites_view.dart';
import 'widgets/folder_list_view.dart';
import 'widgets/credential_list_widget.dart';
import 'widgets/empty_state_widget.dart';

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final credentialsAsync = ref.watch(filteredCredentialsProvider);
    final foldersAsync = ref.watch(foldersNotifierProvider);

    final credentials = credentialsAsync.valueOrNull ?? [];
    List<Credential> filtered = [];

    if (_currentIndex == 0) {
      filtered = credentials;
    } else if (_currentIndex == 2) {
      filtered = credentials.where((c) => c.isFavorite).toList();
    }

    return Scaffold(
      appBar: VaultAppBar(
        title: 'SoloKey',
        actions: [
          IconButton(
            icon: Icon(Icons.lock_rounded, color: palette.danger),
            tooltip: l10n.homeLockTooltip,
            onPressed: () {
              HapticFeedback.heavyImpact();
              ref.read(vaultNotifierProvider.notifier).lock();
              context.go(AppRoutes.unlock);
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: palette.textPrimary),
            color: palette.drawer,
            onSelected: (val) {
              if (val == 'audit') context.push(AppRoutes.securityAudit);
              if (val == 'settings') context.push(AppRoutes.settings);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'audit',
                child: Row(
                  children: [
                    Icon(Icons.security_rounded, color: palette.textPrimary, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.navAudit, style: TextStyle(color: palette.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded, color: palette.textPrimary, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.navSettings, style: TextStyle(color: palette.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => ref.read(credentialSearchNotifierProvider.notifier).update(v),
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.homeSearchHint,
                prefixIcon: Icon(Icons.search_rounded, color: palette.textMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: palette.textMuted),
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
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 2
          ? null // No FAB on Favorites tab
          : FloatingActionButton.extended(
              onPressed: _currentIndex == 1
                  ? () => _createRootFolder(context, ref)
                  : () => context.push(AppRoutes.credentialCreate),
              backgroundColor: palette.accent,
              icon: Icon(
                _currentIndex == 1 ? Icons.create_new_folder_rounded : Icons.add_rounded,
                color: palette.onPrimary,
              ),
              label: Text(
                _currentIndex == 1 ? l10n.homeFabFolder : l10n.homeFabNew,
                style: TextStyle(color: palette.onPrimary, fontWeight: FontWeight.w600),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: palette.background,
        selectedItemColor: palette.accent,
        unselectedItemColor: palette.textDisabled,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.all_inbox_rounded),
              label: l10n.navCredentials),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_tree_rounded),
              label: l10n.navFolders),
          BottomNavigationBarItem(
              icon: const Icon(Icons.star_rounded), label: l10n.navFavorites),
        ],
      ),
      body: RefreshIndicator(
        color: palette.accent,
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
                : (_currentIndex == 1)
                    ? FolderListView(
                        folders: foldersAsync.valueOrNull ?? [],
                        credentials: credentials,
                      )
                    : (_currentIndex == 2)
                        ? FavoritesView(
                            folders: foldersAsync.valueOrNull ?? [],
                            credentials: credentials,
                          )
                        : filtered.isEmpty
                            ? EmptyStateWidget(
                                message: l10n.homeEmptyVault,
                                onAdd: () => context.push(AppRoutes.credentialCreate),
                              )
                            : CredentialListWidget(credentials: filtered),
      ),
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
