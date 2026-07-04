import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault_access/application/unlock_vault_use_case.dart';
import 'package:password_manager/features/vault_access/application/vault_exceptions.dart';
import 'package:password_manager/features/vault_access/application/vault_state_provider.dart';
import 'package:password_manager/features/vault_access/domain/entities/vault_session.dart';

/// Fake unlock use case whose [execute] throws a preconfigured error, so we can
/// assert how [VaultNotifier] maps each domain exception onto a SEMANTIC
/// [VaultErrorKind] (never a hardcoded, unlocalized string).
class _FakeUnlockUseCase implements UnlockVaultUseCase {
  _FakeUnlockUseCase(this._onExecute);
  final Future<VaultSession> Function() _onExecute;

  @override
  Future<VaultSession> execute(String masterPassword) => _onExecute();

  @override
  Future<VaultSession> executeBiometrics() =>
      throw UnimplementedError('not used');

  @override
  Future<VaultSession> executeWithRawKey(Uint8List keyBytes) =>
      throw UnimplementedError('not used');

  @override
  void lock() {}
}

ProviderContainer _containerThrowing(Object error) {
  final container = ProviderContainer(
    overrides: [
      unlockVaultUseCaseProvider.overrideWithValue(
        _FakeUnlockUseCase(() => throw error),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('VaultNotifier.unlock error mapping', () {
    test('lockout exception → lockedOut kind carrying the remaining duration',
        () async {
      const remaining = Duration(seconds: 30);
      final container =
          _containerThrowing(const VaultLockedOutException(remaining));

      await container.read(vaultNotifierProvider.notifier).unlock('secret');

      final state = container.read(vaultNotifierProvider);
      state.maybeWhen(
        error: (kind, lockout, message) {
          expect(kind, VaultErrorKind.lockedOut);
          expect(lockout, remaining);
          expect(message, isNull);
        },
        orElse: () => fail('expected error state, got $state'),
      );
    });

    test('wrong password within free attempts → wrongPassword, no lockout',
        () async {
      final container =
          _containerThrowing(const WrongMasterPasswordException(Duration.zero));

      await container.read(vaultNotifierProvider.notifier).unlock('secret');

      container.read(vaultNotifierProvider).maybeWhen(
            error: (kind, lockout, message) {
              expect(kind, VaultErrorKind.wrongPassword);
              expect(lockout, isNull);
            },
            orElse: () => fail('expected error state'),
          );
    });

    test('wrong password with backoff → wrongPassword carrying the lockout',
        () async {
      const backoff = Duration(seconds: 15);
      final container =
          _containerThrowing(const WrongMasterPasswordException(backoff));

      await container.read(vaultNotifierProvider.notifier).unlock('secret');

      container.read(vaultNotifierProvider).maybeWhen(
            error: (kind, lockout, message) {
              expect(kind, VaultErrorKind.wrongPassword);
              expect(lockout, backoff);
            },
            orElse: () => fail('expected error state'),
          );
    });

    test('wiped exception → wiped kind', () async {
      final container = _containerThrowing(const VaultWipedException());

      await container.read(vaultNotifierProvider.notifier).unlock('secret');

      container.read(vaultNotifierProvider).maybeWhen(
            error: (kind, lockout, message) =>
                expect(kind, VaultErrorKind.wiped),
            orElse: () => fail('expected error state'),
          );
    });

    test('unexpected error → generic kind with a raw detail message', () async {
      final container = _containerThrowing(StateError('boom'));

      await container.read(vaultNotifierProvider.notifier).unlock('secret');

      container.read(vaultNotifierProvider).maybeWhen(
            error: (kind, lockout, message) {
              expect(kind, VaultErrorKind.generic);
              expect(message, contains('boom'));
            },
            orElse: () => fail('expected error state'),
          );
    });
  });
}
