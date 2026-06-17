import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/di/provider_overrides.dart';

Future<void> main() async {
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

      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
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
          await windowManager.show();
          await windowManager.focus();
        });
      }

      runApp(
        ProviderScope(
          overrides: buildProviderOverrides(),
          child: const App(),
        ),
      );
    },
    (error, stack) {
      // Zone-level error handler — last resort safety net.
    },
  );
}
