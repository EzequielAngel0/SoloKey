import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_health_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/presentation/widgets/credential_card.dart';
import 'package:password_manager/shared/widgets/status_chip.dart';

import '../../../support/widget_harness.dart';

Credential _c({
  String id = '1',
  String title = 'GitHub',
  String? username,
  String? password,
  CredentialType type = CredentialType.password,
  bool favorite = false,
  bool doubleEnc = false,
}) =>
    Credential(
      id: id,
      type: type,
      title: title,
      username: username,
      password: password,
      isFavorite: favorite,
      isDoubleEncrypted: doubleEnc,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

Finder _monoCode() => find.byWidgetPredicate(
    (w) => w is Text && w.data != null && RegExp(r'^\d{3} \d{3}$').hasMatch(w.data!));

Future<void> pumpCard(
  WidgetTester tester,
  Credential credential, {
  Map<String, Set<CredentialHealth>> health = const {},
}) =>
    pumpApp(
      tester,
      scaffolded(CredentialCard(credential: credential)),
      overrides: [credentialHealthProvider.overrideWithValue(health)],
    );

void main() {
  group('CredentialCard — basic layout', () {
    testWidgets('shows title and username subtitle', (tester) async {
      await pumpCard(tester, _c(username: 'octocat'));
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('octocat'), findsOneWidget);
    });

    testWidgets('shows a chevron for non-TOTP types', (tester) async {
      await pumpCard(tester, _c());
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('favorite renders the star marker', (tester) async {
      await pumpCard(tester, _c(favorite: true));
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('non-favorite has no star marker', (tester) async {
      await pumpCard(tester, _c(favorite: false));
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('double-encrypted renders the enhanced-encryption marker',
        (tester) async {
      await pumpCard(tester, _c(doubleEnc: true));
      expect(find.byIcon(Icons.enhanced_encryption_rounded), findsOneWidget);
    });
  });

  group('CredentialCard — health chip', () {
    testWidgets('no chip when the vault is healthy', (tester) async {
      await pumpCard(tester, _c());
      expect(find.byType(StatusChip), findsNothing);
    });

    testWidgets('weak → warning chip', (tester) async {
      await pumpCard(tester, _c(),
          health: {'1': {CredentialHealth.weak}});
      expect(find.byType(StatusChip), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('reused takes precedence with the copy chip', (tester) async {
      await pumpCard(tester, _c(),
          health: {'1': {CredentialHealth.weak, CredentialHealth.reused}});
      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });
  });

  group('CredentialCard — TOTP inline', () {
    testWidgets('valid base32 secret renders a 6-digit code', (tester) async {
      await pumpCard(
        tester,
        _c(type: CredentialType.totp, password: 'JBSWY3DPEHPK3PXP'),
      );
      // Timer.periodic(1s) is alive — pump a frame, never pumpAndSettle.
      await tester.pump(const Duration(milliseconds: 50));
      expect(_monoCode(), findsOneWidget);
      // No chevron for TOTP rows.
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('invalid secret shows the "Invalid" label, not a code',
        (tester) async {
      await pumpCard(
        tester,
        _c(type: CredentialType.totp, password: 'not-valid-base32!!!'),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(_monoCode(), findsNothing);
      expect(find.text('Invalid'), findsOneWidget);
    });
  });
}
