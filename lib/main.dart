import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/di/provider_overrides.dart';
import 'core/services/notification_service.dart';

/// WorkManager background entry point (Android). Runs in its own isolate, so it
/// opens a fresh DB handle and notifies without GetIt or the master key.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background isolates don't auto-register plugins; without this the DB
    // (path_provider/sqlite) and notification plugin fail to load.
    DartPluginRegistrant.ensureInitialized();
    await runBackgroundRotationCheck();
    return true;
  });
}

Future<void> main(List<String> args) async {
  // Autostart pasa '--minimized' para arrancar oculto en la bandeja.
  final startMinimized = args.contains('--minimized');

  // Capture Flutter framework errors (widget build failures, layout, etc.)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // In production: forward to a crash reporter (Sentry, Crashlytics) if
    // opted in. Never print secrets — Zero-Print Policy.
  };

  // Capture Dart async errors not caught by Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    // Silently handled — prevents crash. Same prod forwarding note applies.
    return true;
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDependencies();

      final notifications = getIt<NotificationService>();
      final isDesktop = !kIsWeb &&
          (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

      if (isDesktop) {
        await localNotifier.setup(appName: 'SoloKey');

        // Autostart (registro HKCU\...\Run en Windows). El toggle en Ajustes
        // llama a enable()/disable(); aqui solo configuramos la ruta + arg.
        launchAtStartup.setup(
          appName: 'SoloKey',
          appPath: Platform.resolvedExecutable,
          args: ['--minimized'],
        );

        await windowManager.ensureInitialized();
        await windowManager.setPreventClose(true);
        const windowOptions = WindowOptions(
          size: Size(1080, 780),
          minimumSize: Size(850, 650),
          center: true,
          title: "SoloKey Secure Vault",
          titleBarStyle: TitleBarStyle.normal,
        );
        windowManager.waitUntilReadyToShow(windowOptions, () async {
          if (startMinimized) {
            // Arranque automatico: queda en la bandeja (icono del tray).
            await windowManager.hide();
          } else {
            await windowManager.show();
            await windowManager.focus();
          }
        });
      }

      // Android: schedule a daily background rotation sweep + foreground setup.
      if (!kIsWeb && Platform.isAndroid) {
        await Workmanager().initialize(callbackDispatcher);
        await Workmanager().registerPeriodicTask(
          'solokey-rotation-check',
          'rotationCheck',
          frequency: const Duration(hours: 24),
          initialDelay: const Duration(hours: 1),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        );
        await notifications.initialize();
      }

      runApp(
        ProviderScope(
          overrides: buildProviderOverrides(),
          child: const App(),
        ),
      );

      // Desktop tray daemon: periodic in-process rotation sweeps.
      if (isDesktop) {
        notifications.startDesktopDaemon();
      }
    },
    (error, stack) {
      // Zone-level error handler — last resort safety net.
    },
  );
}
