import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Localized coarse "x ago" label for a timestamp. Falls back to an absolute
/// medium date once the value is older than ~30 days so old items don't read as
/// "412 d ago". Shared across screens (UX overhaul L0 kit).
String relativeTime(AppLocalizations l10n, DateTime t, {String? locale}) {
  final diff = DateTime.now().difference(t);
  if (diff.isNegative || diff.inMinutes < 1) return l10n.relativeNow;
  if (diff.inMinutes < 60) return l10n.relativeMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.relativeHours(diff.inHours);
  if (diff.inDays < 30) return l10n.relativeDays(diff.inDays);
  return DateFormat.yMMMd(locale).format(t);
}
