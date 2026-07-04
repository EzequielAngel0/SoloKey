import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/vault_session.dart';
import '../../../app/di/injection.dart';
import '../../../core/infrastructure/clipboard/clipboard_service.dart';
import 'setup_vault_use_case.dart';
import 'unlock_vault_use_case.dart';
import 'vault_exceptions.dart';

part 'vault_state_provider.freezed.dart';
part 'vault_state_provider.g.dart';

/// Semantic reason of an unlock/setup failure. The notifier lives in the
/// application layer (no `BuildContext`), so it MUST NOT build user-facing
/// strings — it reports the reason and the presentation layer localizes it via
/// `AppLocalizations`. Keeps the Zero-hardcoded-i18n rule intact.
enum VaultErrorKind {
  /// The master password did not match (optionally with a fresh lockout).
  wrongPassword,

  /// An attempt was rejected because a brute-force lockout is active.
  lockedOut,

  /// The vault was wiped after reaching the failed-attempt threshold.
  wiped,

  /// Biometric / Windows Hello unlock failed or is not configured.
  biometricFailed,

  /// WiFi/remote unlock failed.
  remoteFailed,

  /// Any other/unexpected failure ([message] carries the raw detail, if any).
  generic,
}

@freezed
class VaultState with _$VaultState {
  const factory VaultState.initial() = _Initial;
  const factory VaultState.loading() = _Loading;
  const factory VaultState.unlocked(VaultSession session) = _Unlocked;
  const factory VaultState.locked() = _Locked;
  const factory VaultState.error({
    @Default(VaultErrorKind.generic) VaultErrorKind kind,
    Duration? lockout,
    String? message,
  }) = _Error;
}

@riverpod
class VaultNotifier extends _$VaultNotifier {
  @override
  VaultState build() => const VaultState.initial();

  Future<void> setup(String masterPassword) async {
    state = const VaultState.loading();
    try {
      final useCase = ref.read(setupVaultUseCaseProvider);
      final session = await useCase.execute(masterPassword);
      state = VaultState.unlocked(session);
    } catch (e) {
      state = VaultState.error(message: e.toString());
    }
  }

  Future<void> unlock(String masterPassword) async {
    state = const VaultState.loading();
    try {
      final useCase = ref.read(unlockVaultUseCaseProvider);
      final session = await useCase.execute(masterPassword);
      state = VaultState.unlocked(session);
    } on VaultLockedOutException catch (e) {
      state = VaultState.error(
          kind: VaultErrorKind.lockedOut, lockout: e.remaining);
    } on WrongMasterPasswordException catch (e) {
      state = VaultState.error(
        kind: VaultErrorKind.wrongPassword,
        lockout: e.lockoutAfter > Duration.zero ? e.lockoutAfter : null,
      );
    } on VaultWipedException {
      state = const VaultState.error(kind: VaultErrorKind.wiped);
    } on ArgumentError {
      state = const VaultState.error(kind: VaultErrorKind.wrongPassword);
    } catch (e) {
      state = VaultState.error(message: e.toString());
    }
  }

  Future<void> unlockWithBiometrics() async {
    state = const VaultState.loading();
    try {
      final useCase = ref.read(unlockVaultUseCaseProvider);
      final session = await useCase.executeBiometrics();
      state = VaultState.unlocked(session);
    } catch (e) {
      state = const VaultState.error(kind: VaultErrorKind.biometricFailed);
    }
  }

  /// Unlocks with a raw master key obtained via WiFi remote-unlock (DUK).
  Future<void> unlockWithRawKey(Uint8List key) async {
    state = const VaultState.loading();
    try {
      final useCase = ref.read(unlockVaultUseCaseProvider);
      final session = await useCase.executeWithRawKey(key);
      state = VaultState.unlocked(session);
    } catch (e) {
      state = const VaultState.error(kind: VaultErrorKind.remoteFailed);
    }
  }

  void lock() {
    ref.read(unlockVaultUseCaseProvider).lock();
    getIt<ClipboardService>().clearNow();
    state = const VaultState.locked();
  }
}

// ── Use case providers (bridge get_it → Riverpod) ────────────────────────────

@riverpod
SetupVaultUseCase setupVaultUseCase(Ref ref) {
  // Resolved by get_it; imported via injection.dart in real wiring.
  // Overridden in tests via ProviderContainer overrides.
  throw UnimplementedError('Register via get_it override');
}

@riverpod
UnlockVaultUseCase unlockVaultUseCase(Ref ref) {
  throw UnimplementedError('Register via get_it override');
}
