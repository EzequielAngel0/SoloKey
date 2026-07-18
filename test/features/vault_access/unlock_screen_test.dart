import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:password_manager/app/di/injection.dart';
import 'package:password_manager/features/sync/domain/i_sync_service.dart';
import 'package:password_manager/features/vault_access/application/unlock_vault_use_case.dart';
import 'package:password_manager/features/vault_access/application/vault_exceptions.dart';
import 'package:password_manager/features/vault_access/application/vault_state_provider.dart';
import 'package:password_manager/features/vault_access/domain/entities/vault_session.dart';
import 'package:password_manager/features/vault_access/presentation/unlock_screen.dart';
import 'package:password_manager/l10n/app_localizations.dart';
import 'package:password_manager/router/app_router.dart';
import 'package:password_manager/shared/widgets/secure_keyboard/secure_keyboard.dart';
import 'package:password_manager/theme/app_theme.dart';

import '../../support/fake_sync_service.dart';
import '../../support/widget_harness.dart';

/// Accepts exactly [password]; anything else is a wrong master password.
/// [executeWithRawKey] keeps BOTH the buffer reference and a copy of its bytes
/// at call time, so tests can assert the screen zeroes the buffer afterwards
/// without ever printing key material (Zero-Print).
class _FakeUnlockUseCase implements UnlockVaultUseCase {
  _FakeUnlockUseCase({this.password = 'abc'});

  final String password;
  Uint8List? rawKeyRef;
  Uint8List? rawKeyCopy;

  static VaultSession get _session =>
      VaultSession.unlocked(autoLockMinutes: 5);

  @override
  Future<VaultSession> execute(String masterPassword) async {
    if (masterPassword == password) return _session;
    throw const WrongMasterPasswordException(Duration.zero);
  }

  @override
  Future<VaultSession> executeBiometrics() =>
      throw UnimplementedError('not used');

  @override
  Future<VaultSession> executeWithRawKey(Uint8List keyBytes) async {
    rawKeyRef = keyBytes;
    rawKeyCopy = Uint8List.fromList(keyBytes);
    return _session;
  }

  @override
  void lock() {}
}

/// Pumps the UnlockScreen inside a real GoRouter so `context.go/push` work,
/// with `/home` and `/recovery` stubbed out as marker texts.
Future<void> _pumpUnlockWithRouter(
  WidgetTester tester, {
  required _FakeUnlockUseCase useCase,
}) async {
  tolerateInkHiddenPaintWarnings();
  final router = GoRouter(
    initialLocation: AppRoutes.unlock,
    routes: [
      GoRoute(
        path: AppRoutes.unlock,
        builder: (_, _) => const UnlockScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        builder: (_, _) => const Scaffold(body: Text('RECOVERY')),
      ),
    ],
  );
  await tester.binding.setSurfaceSize(const Size(440, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [unlockVaultUseCaseProvider.overrideWithValue(useCase)],
      child: MaterialApp.router(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Drives the SecureKeyboard sheet end-to-end: opens it from the password
/// field, taps one key per character (the shuffled layout is irrelevant — keys
/// are found by their label) and confirms. Frame bumps, never pumpAndSettle
/// (the key-press feedback animation is alive between taps).
Future<void> enterMasterPassword(WidgetTester tester, String password) async {
  await tester.tap(find.text('Tap to enter your password'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400)); // sheet slide-in

  for (final ch in password.split('')) {
    await tester.tap(
      find
          .descendant(
            of: find.byType(SecureKeyboard),
            matching: find.text(ch),
          )
          .first,
    );
    await tester.pump(const Duration(milliseconds: 150));
  }

  await tester.tap(
    find.descendant(
      of: find.byType(SecureKeyboard),
      matching: find.text('Unlock'),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400)); // sheet close + result
}

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
    // No biometrics → master password is primary (the only ElevatedButton).
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint_rounded), findsNothing);
  });

  testWidgets('with biometrics available it is the primary action',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    // Report biometrics present so the primary biometric CTA renders. The
    // settings read that would fire the auto-prompt is guarded (get_it is not
    // registered here), so no native dialog is attempted.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (call) async {
        if (call.method == 'getAvailableBiometrics' ||
            call.method == 'getEnrolledBiometrics') {
          return <String>['fingerprint'];
        }
        // canCheckBiometrics → true; authenticate stays false (unused here).
        return call.method == 'canCheckBiometrics';
      },
    );

    await pumpApp(
      tester,
      const UnlockScreen(),
      surfaceSize: const Size(440, 1000),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    // Primary CTA is the biometric button (with the fingerprint icon on mobile).
    expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    // The master-password fallback is still offered.
    expect(find.text('or use your master password'), findsOneWidget);
  });

  testWidgets('correct master password unlocks and navigates home',
      (tester) async {
    final useCase = _FakeUnlockUseCase(password: 'abc');
    await _pumpUnlockWithRouter(tester, useCase: useCase);

    await enterMasterPassword(tester, 'abc');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('wrong master password shows the error and does NOT navigate',
      (tester) async {
    final useCase = _FakeUnlockUseCase(password: 'abc');
    await _pumpUnlockWithRouter(tester, useCase: useCase);

    await enterMasterPassword(tester, 'zzz');
    await tester.pump(const Duration(milliseconds: 100));

    // Localized error surfaces in a SnackBar; the unlock screen stays put.
    expect(find.text('Incorrect master password'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
    expect(find.byType(UnlockScreen), findsOneWidget);
    // SnackBar auto-dismisses on its own timer — flush it before teardown.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets(
      'remote unlock event unlocks with the raw key and zeroes the buffer',
      (tester) async {
    // The remote-unlock listener only arms on desktop platforms. The override
    // MUST be reset inside the test body — the binding verifies foundation
    // variables before addTearDown callbacks run.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    final sync = FakeSyncService();
    getIt.registerSingleton<ISyncService>(sync);
    addTearDown(() async {
      getIt.unregister<ISyncService>();
      await sync.dispose();
    });

    final useCase = _FakeUnlockUseCase();
    await _pumpUnlockWithRouter(tester, useCase: useCase);

    // A known test key (NOT a real secret): 32 distinct bytes.
    final key = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
    sync.emitServer('remote_unlock_key:${base64Encode(key)}');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // One more frame pair: context.go() fires at the end of the async unlock
    // chain, and the pushed route still needs a build + transition frame.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    try {
      // The use case received exactly the decoded key…
      expect(useCase.rawKeyCopy, key);
      // …and the screen zeroed the shared buffer right after using it.
      expect(useCase.rawKeyRef, everyElement(0));
      // Successful remote unlock lands on home.
      expect(find.text('HOME'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('forgot-password link navigates to recovery', (tester) async {
    await _pumpUnlockWithRouter(tester, useCase: _FakeUnlockUseCase());

    await tester.tap(find.text('Forgot your master password?'));
    await tester.pumpAndSettle();

    expect(find.text('RECOVERY'), findsOneWidget);
  });
}
