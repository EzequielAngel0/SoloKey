import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/vault_session.dart';
import 'setup_vault_use_case.dart';
import 'unlock_vault_use_case.dart';
import 'vault_exceptions.dart';

part 'vault_state_provider.freezed.dart';
part 'vault_state_provider.g.dart';

@freezed
class VaultState with _$VaultState {
  const factory VaultState.initial() = _Initial;
  const factory VaultState.loading() = _Loading;
  const factory VaultState.unlocked(VaultSession session) = _Unlocked;
  const factory VaultState.locked() = _Locked;
  const factory VaultState.error(String message) = _Error;
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
      state = VaultState.error(e.toString());
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
          'Demasiados intentos. Espera ${_formatLockout(e.remaining)}.');
    } on WrongMasterPasswordException catch (e) {
      state = e.lockoutAfter > Duration.zero
          ? VaultState.error(
              'Contraseña incorrecta. Bloqueado ${_formatLockout(e.lockoutAfter)}.')
          : const VaultState.error('Contraseña maestra incorrecta');
    } on VaultWipedException {
      state = const VaultState.error(
          'Bóveda borrada por demasiados intentos fallidos.');
    } on ArgumentError {
      state = const VaultState.error('Contraseña maestra incorrecta');
    } catch (e) {
      state = VaultState.error(e.toString());
    }
  }

  static String _formatLockout(Duration d) {
    if (d.inMinutes >= 1) {
      final s = d.inSeconds % 60;
      return s > 0 ? '${d.inMinutes}m ${s}s' : '${d.inMinutes}m';
    }
    return '${d.inSeconds}s';
  }

  Future<void> unlockWithBiometrics() async {
    state = const VaultState.loading();
    try {
      final useCase = ref.read(unlockVaultUseCaseProvider);
      final session = await useCase.executeBiometrics();
      state = VaultState.unlocked(session);
    } catch (e) {
      state = const VaultState.error('Autenticación biométrica fallida o no configurada.');
    }
  }

  void lock() {
    ref.read(unlockVaultUseCaseProvider).lock();
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
