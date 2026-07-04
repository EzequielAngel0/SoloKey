import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

import '../core/infrastructure/security/app_lifecycle_observer.dart';
import '../core/services/notification_service.dart';
import '../core/services/scheduled_backup_service.dart';
import '../features/sync/application/sync_status_provider.dart';
import '../features/sync/infrastructure/sync_service.dart';
import '../features/settings/domain/repositories/i_settings_repository.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/vault_access/application/vault_state_provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/language_mode.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../theme/app_transitions.dart';
import '../theme/ui_density.dart';
import 'di/injection.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WindowListener, TrayListener {
  late final AppLifecycleObserver _observer;
  Timer? _trayLockTimer;
  Timer? _saveBoundsTimer;
  StreamSubscription<String>? _approvalSub;

  @override
  void initState() {
    super.initState();
    _observer = getIt<AppLifecycleObserver>();
    _observer.initialize();
    _observer.onLockRequested = () {
      if (mounted) {
        ref.read(vaultNotifierProvider.notifier).lock();
      }
    };

    // Instantiate the app-wide sync status provider so it starts listening from
    // launch: it refreshes the vault lists the moment a background delta lands
    // (server residente) and drives the sidebar sync badge. Kept alive by
    // keepAlive:true. Guarded because DI/SyncService may be absent in tests.
    try {
      ref.read(syncStatusProvider);
    } catch (_) {
      // Sync layer unavailable (e.g. widget tests without DI) — ignore.
    }

    // M3: en movil, cuando el escritorio pide aprobacion de login por el canal
    // E2EE, mostramos una notificacion local (sin FCM). Al tocarla se abre la
    // pantalla de Sincronizar para aprobar con biometria.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        _approvalSub = getIt<SyncService>().clientEvents.listen((event) {
          if (event == 'approval_request') {
            getIt<NotificationService>().showLoginApprovalRequest();
          }
        });
      } catch (_) {
        // SyncService/NotificationService pueden no existir en tests.
      }
    }

    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      windowManager.addListener(this);
      trayManager.addListener(this);
      _initSystemTray();
    }
  }

  @override
  void dispose() {
    _cancelTrayLockTimer();
    _saveBoundsTimer?.cancel();
    _approvalSub?.cancel();
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
    }
    _observer.dispose();
    super.dispose();
  }

  Future<void> _initSystemTray() async {
    try {
      // Windows tray needs a small multi-res .ico; the large PNG fails to
      // render in the 16×16 notification area. Other platforms use the PNG.
      await trayManager.setIcon(
        Platform.isWindows
            ? 'assets/logo/SoloKey.ico'
            : 'assets/logo/SoloKey.png',
      );
      final menu = Menu(
        items: [
          MenuItem(
            key: 'show_window',
            label: 'Mostrar Bóveda',
          ),
          MenuItem(
            key: 'lock_vault',
            label: 'Bloquear',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit_app',
            label: 'Salir',
          ),
        ],
      );
      await trayManager.setContextMenu(menu);
    } catch (_) {
      // Best-effort
    }
  }

  Future<void> _startTrayLockTimer() async {
    _trayLockTimer?.cancel();
    // Read the authoritative persisted timeout rather than the (possibly
    // still-loading) settings provider, so minimising to tray respects the
    // user's configured timeout instead of falling back to a short default.
    int minutes;
    try {
      final settings = await getIt<ISettingsRepository>().getSettings();
      minutes = settings.autoLockMinutes;
    } catch (_) {
      minutes =
          ref.read(settingsNotifierProvider).valueOrNull?.autoLockMinutes ?? 5;
    }
    _trayLockTimer = Timer(Duration(minutes: minutes), () {
      ref.read(vaultNotifierProvider.notifier).lock();
    });
  }

  void _cancelTrayLockTimer() {
    _trayLockTimer?.cancel();
    _trayLockTimer = null;
  }

  @override
  void onWindowClose() async {
    final isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
      _startTrayLockTimer();
    }
  }

  @override
  void onWindowMinimize() {
    _startTrayLockTimer();
  }

  @override
  void onWindowRestore() {
    _cancelTrayLockTimer();
  }

  @override
  void onWindowFocus() {
    _cancelTrayLockTimer();
  }

  @override
  void onWindowResized() => _scheduleSaveBounds();

  @override
  void onWindowMoved() => _scheduleSaveBounds();

  /// Debounces bounds persistence so a drag/resize gesture writes once when it
  /// settles, not per frame.
  void _scheduleSaveBounds() {
    _saveBoundsTimer?.cancel();
    _saveBoundsTimer =
        Timer(const Duration(milliseconds: 600), _persistWindowBounds);
  }

  /// Persists the current window geometry so the next launch restores it. Goes
  /// through the settings provider (single writer) so it never clobbers other
  /// persisted fields. Skips hidden/minimized/maximized states so we only ever
  /// store the "normal" bounds. Best-effort: failures never disrupt the app.
  Future<void> _persistWindowBounds() async {
    try {
      if (!await windowManager.isVisible()) return;
      if (await windowManager.isMinimized() ||
          await windowManager.isMaximized()) {
        return;
      }
      final bounds = await windowManager.getBounds();
      final notifier = ref.read(settingsNotifierProvider.notifier);
      final current = ref.read(settingsNotifierProvider).valueOrNull;
      if (current == null) return;
      await notifier.save(current.copyWith(
        windowWidth: bounds.width,
        windowHeight: bounds.height,
        windowX: bounds.left,
        windowY: bounds.top,
      ));
    } catch (_) {
      // Best-effort; never disrupt the app.
    }
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
    _cancelTrayLockTimer();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      windowManager.show();
      windowManager.focus();
      _cancelTrayLockTimer();
    } else if (menuItem.key == 'lock_vault') {
      ref.read(vaultNotifierProvider.notifier).lock();
    } else if (menuItem.key == 'exit_app') {
      windowManager.destroy();
    }
  }

  void _onUserActivity() => _observer.onUserActivity();

  static const _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SlideUpFadeTransition(),
      TargetPlatform.iOS: SlideUpFadeTransition(),
    },
  );

  @override
  Widget build(BuildContext context) {
    final router = ref.read(appRouterProvider);

    // Backup automatico: al desbloquear, corre un export si esta vencido.
    ref.listen(vaultNotifierProvider, (prev, next) {
      next.maybeWhen(
        unlocked: (_) => getIt<ScheduledBackupService>().runIfDue(),
        orElse: () {},
      );
    });

    // Resolve the active theme reactively from the persisted settings. While the
    // settings are still loading we fall back to the historical dark default.
    final settings = ref.watch(settingsNotifierProvider).valueOrNull;
    final mode = settings == null
        ? AppThemeMode.dark
        : AppThemeMode.fromKey(settings.themeMode);

    // Active locale; null = follow the system language.
    final locale = settings == null
        ? null
        : LanguageMode.fromKey(settings.locale).locale;

    // Visual density picked in Settings ('comfortable' | 'compact'). Applied to
    // every built theme below so the whole UI tightens/relaxes consistently.
    final density = UiDensity.fromKey(settings?.uiDensity).visualDensity;
    ThemeData withExtras(ThemeData t) => t.copyWith(
          pageTransitionsTheme: _pageTransitions,
          visualDensity: density,
        );

    final ThemeData theme;
    ThemeData? darkTheme;
    final ThemeMode themeMode;
    switch (mode) {
      case AppThemeMode.system:
        // Let Flutter pick light/dark based on the OS brightness.
        theme = withExtras(AppTheme.light());
        darkTheme = withExtras(AppTheme.dark());
        themeMode = ThemeMode.system;
      case AppThemeMode.light:
        theme = withExtras(AppTheme.light());
        themeMode = ThemeMode.light;
      case AppThemeMode.dark:
        theme = withExtras(AppTheme.dark());
        themeMode = ThemeMode.light;
      case AppThemeMode.dim:
        theme = withExtras(AppTheme.dim());
        themeMode = ThemeMode.light;
      case AppThemeMode.oled:
        theme = withExtras(AppTheme.oled());
        themeMode = ThemeMode.light;
    }

    return Listener(
      // Reset inactivity timer on any pointer event (tap, scroll, drag).
      onPointerDown: (_) => _onUserActivity(),
      child: MaterialApp.router(
        title: 'SoloKey',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }
}
