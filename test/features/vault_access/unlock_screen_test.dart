import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault_access/presentation/unlock_screen.dart';

import '../../support/widget_harness.dart';

void main() {
  // local_auth talks to a native channel that isn't present in widget tests;
  // returning false for every call = "no biometrics", so the auto-prompt path
  // short-circuits and _checkBiometrics never touches get_it.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (call) async {
        // List-returning methods must not get a bool, or local_auth's cast throws.
        if (call.method == 'getAvailableBiometrics' ||
            call.method == 'getEnrolledBiometrics') {
          return <String>[];
        }
        return false; // canCheckBiometrics / isDeviceSupported / authenticate…
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      null,
    );
  });

  testWidgets('UnlockScreen builds and shows the master-password field',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    // VaultNotifier.build() is `initial()` (no provider reads), and the lockout /
    // remote-unlock get_it calls are guarded, so no overrides are needed.
    await pumpApp(
      tester,
      const UnlockScreen(),
      surfaceSize: const Size(440, 1000),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
