import '../domain/entities/secure_file.dart';

/// Sort orders offered by the secure-files screen.
enum SecureFilesSort { recent, name, size }

/// Pure view pipeline for the secure-files list: text filter (name, note and
/// type hint) + sort, with favourites always pinned first. Extracted from the
/// screen so it is unit-testable (test/features/secure_files/
/// secure_files_view_test.dart) — mirrors the credentials `vault_view` helper.
List<SecureFile> visibleSecureFiles(
  List<SecureFile> files, {
  String query = '',
  SecureFilesSort sort = SecureFilesSort.recent,
}) {
  final q = query.trim().toLowerCase();
  final filtered = q.isEmpty
      ? [...files]
      : [
          for (final f in files)
            if (f.name.toLowerCase().contains(q) ||
                (f.note?.toLowerCase().contains(q) ?? false) ||
                (f.mimeHint?.toLowerCase().contains(q) ?? false))
              f,
        ];
  filtered.sort((a, b) {
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
    return switch (sort) {
      SecureFilesSort.recent => b.createdAt.compareTo(a.createdAt),
      SecureFilesSort.name =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      SecureFilesSort.size => b.sizeBytes.compareTo(a.sizeBytes),
    };
  });
  return filtered;
}
