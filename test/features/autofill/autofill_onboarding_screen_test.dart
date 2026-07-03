import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:password_manager/features/autofill/infrastructure/autofill_settings_service.dart';
import 'package:password_manager/features/autofill/presentation/autofill_onboarding_screen.dart';

import '../../support/widget_harness.dart';

/// The screen's State grabs `getIt<AutofillSettingsService>()` in a field
/// initializer, so we register a fake in get_it (no native channel needed).
class _FakeAutofillSettings extends AutofillSettingsService {
  @override
  Future<bool> isAutofillEnabled() async => false;
  @override
  Future<bool> openAutofillSettings() async => true;
}

void main() {
  setUp(() {
    GetIt.I.registerSingleton<AutofillSettingsService>(_FakeAutofillSettings());
  });
  tearDown(() => GetIt.I.reset());

  testWidgets('AutofillOnboardingScreen builds', (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      const AutofillOnboardingScreen(),
      surfaceSize: const Size(440, 1200),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
