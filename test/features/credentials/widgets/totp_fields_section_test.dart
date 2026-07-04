import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/presentation/widgets/totp_fields_section.dart';
import 'package:password_manager/l10n/app_localizations.dart';
import 'package:password_manager/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('en'),
  theme: AppTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

TotpFieldsSection _section({
  required bool isDesktopScan,
  VoidCallback? onScan,
}) => TotpFieldsSection(
  issuerCtrl: TextEditingController(),
  secretCtrl: TextEditingController(),
  onScan: onScan ?? () {},
  onPaste: () {},
  secretValidator: (_) => null,
  isDesktopScan: isDesktopScan,
);

void main() {
  testWidgets('desktop variant shows the screen-scan label and fires onScan', (
    tester,
  ) async {
    var scans = 0;
    await tester.pumpWidget(
      _wrap(_section(isDesktopScan: true, onScan: () => scans++)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Scan QR from screen'), findsOneWidget);
    expect(find.text('Scan QR code'), findsNothing);

    await tester.tap(find.text('Scan QR from screen'));
    expect(scans, 1);
  });

  testWidgets('mobile variant shows the camera-scan label', (tester) async {
    await tester.pumpWidget(_wrap(_section(isDesktopScan: false)));
    await tester.pumpAndSettle();

    expect(find.text('Scan QR code'), findsOneWidget);
    expect(find.text('Scan QR from screen'), findsNothing);
  });
}
