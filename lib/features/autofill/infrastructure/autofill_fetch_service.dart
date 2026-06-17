import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../app/di/injection.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../../credentials/domain/repositories/i_credential_repository.dart';
import '../application/autofill_matcher.dart';

/// Decrypts and matches credentials for an Android autofill request.
///
/// This runs inside the short-lived `autofillEntrypoint` isolate, where the
/// vault session starts empty. It loads the biometric-wrapped master key
/// (`bio_master_key`, written by `UnlockVaultUseCase` when biometric unlock is
/// enabled) into the [SessionManager] so the repository can decrypt, then
/// returns ONLY the plaintext fields the OS autofill framework needs.
///
/// Security:
///  - Only reachable AFTER the native [AutofillAuthActivity] passed biometric
///    auth, so the master key never loads without user presence.
///  - Returns empty when no biometric key exists (autofill requires the user
///    to enable biometric unlock first) — never derives from a typed password.
@lazySingleton
class AutofillFetchService {
  AutofillFetchService(this._credRepo, this._session);

  final ICredentialRepository _credRepo;
  final SessionManager _session;

  static const _bioKeyName = 'bio_master_key';

  /// Returns `[{title, username, password}]` for credentials matching the
  /// caller [package] / [domain]. Empty if the vault cannot be unlocked.
  Future<List<Map<String, String>>> fetchMatches({
    required String package,
    required String domain,
  }) async {
    if (!await _ensureSessionKey()) return const [];

    final all = await _credRepo.getAll();
    final matches = AutofillMatcher.match(
      all,
      packageName: package,
      webDomain: domain,
    );

    return matches
        .map((c) => <String, String>{
              'title': c.title,
              'username': c.username ?? '',
              'password': c.password ?? '',
            })
        .toList();
  }

  /// Loads `bio_master_key` into the session if absent. Returns whether a key
  /// is now available. The decoded buffer is zeroed right after handing a copy
  /// to the session.
  Future<bool> _ensureSessionKey() async {
    if (_session.hasActiveKey) return true;
    final keyB64 =
        await getIt<FlutterSecureStorage>().read(key: _bioKeyName);
    if (keyB64 == null || keyB64.isEmpty) return false;

    final bytes = Uint8List.fromList(base64Decode(keyB64));
    _session.storeKey(bytes);
    bytes.fillRange(0, bytes.length, 0);
    return true;
  }
}
