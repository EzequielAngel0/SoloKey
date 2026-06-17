import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../domain/crypto_utils.dart';

/// Holds the derived master key in memory for the duration of an unlocked session.
/// The key is zeroed out when the vault is locked.
///
/// Security note: Dart's GC may keep copies of Uint8List in memory beyond the
/// zero-fill. This minimises the exposure window but cannot guarantee full
/// memory security — that requires native/FFI approaches (future enhancement).
@LazySingleton()
class SessionManager {
  Uint8List? _keyBytes;

  bool get hasActiveKey => _keyBytes != null;

  /// Stores the derived key. Call only after successful master password verification.
  void storeKey(Uint8List keyBytes) {
    _clearBuffer();
    _keyBytes = Uint8List.fromList(keyBytes);
  }

  /// Returns a copy of the key bytes. Returns null if session is locked.
  Uint8List? getKeyCopy() {
    if (_keyBytes == null) return null;
    return Uint8List.fromList(_keyBytes!);
  }

  /// Zeros the key buffer and nullifies the reference.
  void lock() => _clearBuffer();

  void _clearBuffer() {
    if (_keyBytes != null) {
      zeroBuffer(_keyBytes!);
      _keyBytes = null;
    }
  }
}
