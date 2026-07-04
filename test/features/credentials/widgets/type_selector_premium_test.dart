import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/widgets/type_selector_premium.dart';
import 'package:password_manager/l10n/app_localizations.dart';

import '../../../support/widget_harness.dart';

void main() {
  testWidgets('type selector exposes button + selected semantics per item',
      (tester) async {
    CredentialType? picked;
    await pumpApp(
      tester,
      scaffolded(
        TypeSelectorPremium(
          selected: CredentialType.password,
          onChanged: (t) => picked = t,
        ),
      ),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(TypeSelectorPremium)),
    );

    // The active item announces itself as a *selected* button (not just text).
    expect(
      tester.getSemantics(find.bySemanticsLabel(l10n.typePassword)),
      isSemantics(isButton: true, isSelected: true),
    );

    // A non-active item is a button but not selected.
    expect(
      tester.getSemantics(find.bySemanticsLabel(l10n.typeSelTotp)),
      isSemantics(isButton: true, isSelected: false),
    );

    // Tapping it selects that type.
    await tester.tap(find.bySemanticsLabel(l10n.typeSelTotp));
    expect(picked, CredentialType.totp);
  });
}
