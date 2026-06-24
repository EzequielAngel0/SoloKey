import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/notification_navigation.dart';
import '../features/credentials/presentation/credential_detail_screen.dart';
import '../features/credentials/presentation/credential_form_screen.dart';
import '../features/credentials/presentation/home_screen.dart';
import '../features/credentials/presentation/password_history_screen.dart';
import '../features/credentials/presentation/security_audit_screen.dart';
import '../features/autofill/presentation/autofill_onboarding_screen.dart';
import '../features/autofill/presentation/quick_fill_screen.dart';
import '../features/passkeys/presentation/passkeys_screen.dart';
import '../features/vault_transfer/presentation/transfer_screen.dart';
import '../features/secure_files/presentation/secure_files_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/vault_access/application/vault_state_provider.dart';
import '../features/vault_access/presentation/recovery_screen.dart';
import '../features/vault_access/presentation/setup_screen.dart';
import '../features/vault_access/presentation/splash_screen.dart';
import '../features/vault_access/presentation/unlock_screen.dart';
import '../features/credentials/presentation/qr_scanner_screen.dart';
import '../features/folders/presentation/folder_screen.dart';
import '../features/sync/presentation/pairing_screen.dart';

// ── Route constants ───────────────────────────────────────────────────────────

abstract final class AppRoutes {
  static const splash           = '/';
  static const setup            = '/setup';
  static const unlock           = '/unlock';
  static const recovery         = '/recovery';
  static const home             = '/home';
  static const credentialDetail = '/credentials/:id';
  static const passwordHistory  = '/credentials/:id/history';
  static const credentialEdit   = '/credentials/:id/edit';
  static const credentialCreate = '/credentials/create';
  static const folderDetail     = '/folders/:id';
  static const settings         = '/settings';
  static const securityAudit      = '/security-audit';
  static const qrScanner           = '/qr-scanner';
  static const transfer            = '/transfer';
  static const secureFiles         = '/secure-files';
  static const autofillOnboarding  = '/autofill-onboarding';
  static const quickFill           = '/quick-fill';
  static const passkeys            = '/passkeys';
  static const sync                = '/sync';
}

// ── RouterNotifier ────────────────────────────────────────────────────────────
// Wraps the VaultState into a ChangeNotifier so GoRouter can listen to it
// WITHOUT recreating the router instance on every state change.

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<VaultState>(
      vaultNotifierProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;

  VaultState get _state => _ref.read(vaultNotifierProvider);

  String? redirect(_, GoRouterState routerState) {
    final vaultState = _state;

    // While loading never redirect — avoid interrupting async unlock flows
    final isLoading = vaultState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isLoading) return null;

    final isUnlocked = vaultState.maybeWhen(
      unlocked: (_) => true,
      orElse: () => false,
    );

    final loc = routerState.matchedLocation;

    final onProtected = loc.startsWith('/home') ||
        loc.startsWith('/credentials') ||
        loc.startsWith('/password') ||
        loc.startsWith('/settings') ||
        loc.startsWith('/security-audit') ||
        loc.startsWith('/qr-scanner') ||
        loc.startsWith('/transfer') ||
        loc.startsWith('/secure-files') ||
        loc.startsWith('/autofill-onboarding') ||
        loc.startsWith('/quick-fill') ||
        loc.startsWith('/sync');

    // Redirect to unlock if trying to access protected routes while locked
    if (onProtected && !isUnlocked) return AppRoutes.unlock;

    // If already unlocked and still on unlock/splash, go home
    if (isUnlocked &&
        (loc == AppRoutes.unlock || loc == AppRoutes.splash)) {
      return AppRoutes.home;
    }

    return null;
  }
}

// ── Stable provider — GoRouter is created ONCE, never recreated ───────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.setup,
        builder: (_, _) => const SetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.unlock,
        builder: (_, _) => const UnlockScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.credentialCreate,
        builder: (_, _) => const CredentialFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.credentialDetail,
        builder: (context, state) => CredentialDetailScreen(
          credentialId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.passwordHistory,
        builder: (context, state) => PasswordHistoryScreen(
          credentialId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.credentialEdit,
        builder: (_, state) => CredentialFormScreen(
          existingId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.folderDetail,
        builder: (context, state) => FolderScreen(
          folderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.securityAudit,
        builder: (_, _) => const SecurityAuditScreen(),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        builder: (_, _) => const RecoveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.qrScanner,
        builder: (_, _) => const QrScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.transfer,
        builder: (_, _) => const TransferScreen(),
      ),
      GoRoute(
        path: AppRoutes.secureFiles,
        builder: (_, _) => const SecureFilesScreen(),
      ),
      GoRoute(
        path: AppRoutes.autofillOnboarding,
        builder: (_, _) => const AutofillOnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.quickFill,
        builder: (_, _) => const QuickFillScreen(),
      ),
      GoRoute(
        path: AppRoutes.passkeys,
        builder: (_, _) => const PasskeysScreen(),
      ),
      GoRoute(
        path: AppRoutes.sync,
        builder: (_, _) => const PairingScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });

  return router;
});
