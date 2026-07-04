// Pure, UI-agnostic helpers for importing files into the secure store. Kept
// separate from the screen so the size/naming rules can be unit-tested without
// pumping a widget.

/// Hard cap for a single secure file. Contents are held fully in RAM to be
/// encrypted in one shot, so we refuse anything larger to avoid OOM on mobile.
const int kMaxSecureFileBytes = 50 * 1024 * 1024; // 50 MB

/// Whether [sizeBytes] is within the import limit.
bool isWithinSecureFileLimit(int sizeBytes) => sizeBytes <= kMaxSecureFileBytes;

/// Returns [candidate] if no case-insensitive collision exists in [existing],
/// otherwise inserts a ` (n)` suffix before the extension until it is unique
/// (e.g. `id_rsa.pem` → `id_rsa (2).pem`). Dotfiles like `.env` keep their leading
/// dot and get the suffix appended to the whole name.
String uniqueSecureFileName(String candidate, Iterable<String> existing) {
  final taken = existing.map((e) => e.toLowerCase()).toSet();
  if (!taken.contains(candidate.toLowerCase())) return candidate;

  final dot = candidate.lastIndexOf('.');
  final hasExt = dot > 0; // dot > 0 => not a leading-dot dotfile
  final base = hasExt ? candidate.substring(0, dot) : candidate;
  final ext = hasExt ? candidate.substring(dot) : '';

  for (var i = 2;; i++) {
    final next = '$base ($i)$ext';
    if (!taken.contains(next.toLowerCase())) return next;
  }
}

/// Extensions we can decode and preview in-memory with `Image.memory`.
const Set<String> kPreviewableImageExtensions = {
  'png',
  'jpg',
  'jpeg',
  'gif',
  'bmp',
  'webp',
};

/// Whether a file with this [mimeHint] (extension) can be previewed as an image.
bool isPreviewableImage(String? mimeHint) =>
    mimeHint != null && kPreviewableImageExtensions.contains(mimeHint.toLowerCase());

/// Human-readable size, matching the tile formatter (B / KB / MB).
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
