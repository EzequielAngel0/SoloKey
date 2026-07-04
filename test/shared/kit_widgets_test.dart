import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/shared/widgets/password_requirements_checklist.dart';
import 'package:password_manager/shared/widgets/score_ring.dart';
import 'package:password_manager/shared/widgets/solo_filter_chip.dart';
import 'package:password_manager/shared/widgets/status_chip.dart';
import 'package:password_manager/shared/widgets/type_badge.dart';
import 'package:password_manager/theme/app_palette.dart';

import '../support/widget_harness.dart';

/// Pumps [child] and captures the resolved [AppPalette], so colour assertions
/// compare against the real theme tokens instead of hard-coded hex.
Future<AppPalette> _pump(WidgetTester tester, Widget child) async {
  late AppPalette palette;
  await pumpApp(
    tester,
    scaffolded(Builder(builder: (context) {
      palette = context.palette;
      return child;
    })),
  );
  return palette;
}

void main() {
  group('ScoreRing', () {
    CircularProgressIndicator ring(WidgetTester tester) =>
        tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

    testWidgets('high score fills proportionally and is success-colored',
        (tester) async {
      final p = await _pump(tester, const ScoreRing(score: 90));
      expect(ring(tester).value, closeTo(0.9, 0.001));
      expect(ring(tester).color, p.success);
      expect(find.text('90'), findsOneWidget);
    });

    testWidgets('mid score is warning-colored', (tester) async {
      final p = await _pump(tester, const ScoreRing(score: 60));
      expect(ring(tester).value, closeTo(0.6, 0.001));
      expect(ring(tester).color, p.warning);
    });

    testWidgets('low score is danger-colored', (tester) async {
      final p = await _pump(tester, const ScoreRing(score: 20));
      expect(ring(tester).value, closeTo(0.2, 0.001));
      expect(ring(tester).color, p.danger);
    });

    testWidgets('clamps the gauge but shows the raw number', (tester) async {
      final p = await _pump(tester, const ScoreRing(score: 150));
      expect(ring(tester).value, 1.0);
      expect(ring(tester).color, p.success);
      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('a negative score clamps to an empty danger gauge',
        (tester) async {
      final p = await _pump(tester, const ScoreRing(score: -10));
      expect(ring(tester).value, 0.0);
      expect(ring(tester).color, p.danger);
    });
  });

  group('SoloFilterChip', () {
    Material chipMaterial(WidgetTester tester) => tester
        .widgetList<Material>(find.descendant(
          of: find.byType(SoloFilterChip),
          matching: find.byType(Material),
        ))
        .first;

    testWidgets('selected uses the primary fill', (tester) async {
      final p = await _pump(
        tester,
        SoloFilterChip(label: 'Todos', selected: true, onTap: () {}),
      );
      expect(chipMaterial(tester).color, p.primary);
    });

    testWidgets('unselected uses the surface fill', (tester) async {
      final p = await _pump(
        tester,
        SoloFilterChip(label: 'Todos', selected: false, onTap: () {}),
      );
      expect(chipMaterial(tester).color, p.surface);
    });

    testWidgets('tapping invokes onTap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        SoloFilterChip(label: 'TOTP', selected: false, onTap: () => taps++),
      );
      await tester.tap(find.byType(SoloFilterChip));
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('PasswordRequirementsChecklist', () {
    Finder met() => find.byIcon(Icons.check_circle_rounded);
    Finder unmet() => find.byIcon(Icons.radio_button_unchecked_rounded);

    testWidgets('an empty password meets none of the four requirements',
        (tester) async {
      await _pump(tester, const PasswordRequirementsChecklist(password: ''));
      expect(met(), findsNothing);
      expect(unmet(), findsNWidgets(4));
    });

    testWidgets('a compliant master password meets all four', (tester) async {
      // 12+ chars, uppercase, number and symbol.
      await _pump(
        tester,
        const PasswordRequirementsChecklist(password: 'Abcdefghij1!'),
      );
      expect(met(), findsNWidgets(4));
      expect(unmet(), findsNothing);
    });

    testWidgets('a long lowercase-only password meets only the length rule',
        (tester) async {
      await _pump(
        tester,
        const PasswordRequirementsChecklist(password: 'abcdefghijkl'),
      );
      expect(met(), findsOneWidget);
      expect(unmet(), findsNWidgets(3));
    });
  });

  group('StatusChip / TypeBadge render their label', () {
    testWidgets('StatusChip shows its icon and label', (tester) async {
      await _pump(
        tester,
        const StatusChip(
          label: 'Reutilizada',
          color: Color(0xFFEF4444),
          icon: Icons.warning_amber_rounded,
        ),
      );
      expect(find.text('Reutilizada'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('TypeBadge shows its label', (tester) async {
      await _pump(
        tester,
        const TypeBadge(label: 'SSH key', color: Color(0xFF6C63FF)),
      );
      expect(find.text('SSH key'), findsOneWidget);
    });
  });
}
