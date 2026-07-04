import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:password_manager/l10n/app_localizations_en.dart';
import 'package:password_manager/shared/utils/relative_time.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime.now();

  setUpAll(() => initializeDateFormatting('en'));

  test('shows "just now" for sub-minute and future timestamps', () {
    expect(relativeTime(l10n, now), 'just now');
    expect(relativeTime(l10n, now.add(const Duration(hours: 1))), 'just now');
  });

  test('buckets minutes, hours and days', () {
    expect(relativeTime(l10n, now.subtract(const Duration(minutes: 5))),
        '5 min ago');
    expect(
        relativeTime(l10n, now.subtract(const Duration(hours: 3))), '3 h ago');
    expect(
        relativeTime(l10n, now.subtract(const Duration(days: 2))), '2 d ago');
  });

  test('falls back to an absolute date beyond ~30 days', () {
    final old = DateTime(2020, 1, 15);
    final label = relativeTime(l10n, old, locale: 'en');
    expect(label, contains('2020'));
    expect(label, isNot(contains('ago')));
  });
}
