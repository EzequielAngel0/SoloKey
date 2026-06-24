import 'package:freezed_annotation/freezed_annotation.dart';

part 'secure_file.freezed.dart';
part 'secure_file.g.dart';

/// Metadata for a file stored securely on disk.
///
/// The file *contents* are encrypted with AES-256-GCM using the active session
/// key and written to the app's private support directory as [storedFileName].
/// Only this non-sensitive metadata is kept in the database so the list can be
/// shown without unlocking each file.
@freezed
class SecureFile with _$SecureFile {
  const factory SecureFile({
    required String id,

    /// Original file name chosen by the user (e.g. "id_ed25519", "creds.json").
    required String name,

    /// Plaintext size in bytes (for display).
    required int sizeBytes,

    /// Name of the encrypted blob on disk (`<id>.enc`).
    required String storedFileName,

    /// Optional extension/type hint (e.g. "json", "pem").
    String? mimeHint,

    /// Optional user note.
    String? note,

    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SecureFile;

  factory SecureFile.fromJson(Map<String, dynamic> json) =>
      _$SecureFileFromJson(json);
}
