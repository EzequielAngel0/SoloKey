import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/shared/widgets/solo_filter_chip.dart';
import 'package:password_manager/theme/app_palette.dart';
import 'package:password_manager/theme/app_theme.dart';

/// Visual QA (UI-9): the four Graphite Pro themes must each build a screen that
/// exercises the new shared components (filter chips, NavigationBar, buttons,
/// inputs) without throwing, and `context.palette` must resolve to the matching
/// palette. This is the automatable slice of the "4 temas" check.
void main() {
  final themes = <String, (ThemeData, AppPalette)>{
    'dark': (AppTheme.dark(), AppPalette.dark),
    'light': (AppTheme.light(), AppPalette.light),
    'dim': (AppTheme.dim(), AppPalette.dim),
    'oled': (AppTheme.oled(), AppPalette.oled),
  };

  themes.forEach((name, pair) {
    final (theme, palette) = pair;

    testWidgets('Graphite Pro theme "$name" builds core UI without errors',
        (tester) async {
      late AppPalette resolved;
      var selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: StatefulBuilder(
            builder: (context, setState) {
              resolved = context.palette;
              return Scaffold(
                appBar: AppBar(title: const Text('Bóveda')),
                body: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(hintText: 'Buscar…'),
                    ),
                    Row(
                      children: [
                        SoloFilterChip(
                          label: 'Todos',
                          selected: true,
                          onTap: () {},
                        ),
                        SoloFilterChip(
                          label: 'Favoritos',
                          icon: Icons.star_rounded,
                          selected: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Guardar'),
                    ),
                    FilledButton(onPressed: () {}, child: const Text('Generar')),
                  ],
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (i) => setState(() => selected = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      label: 'Bóveda',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.shield_outlined),
                      label: 'Seguridad',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Bóveda'), findsWidgets);
      // The registered ThemeExtension must be the matching Graphite Pro palette.
      expect(resolved.primary, palette.primary);
      expect(resolved.background, palette.background);

      // Tapping a NavigationBar destination must not throw.
      await tester.tap(find.text('Seguridad'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  test('Graphite Pro brand accents are wired (blue + emerald, no legacy neon)',
      () {
    expect(AppPalette.dark.primary, const Color(0xFF3B82F6));
    expect(AppPalette.dark.secondary, const Color(0xFF10B981));
    expect(AppPalette.light.primary, const Color(0xFF2563EB));
    // The fonts are the bundled Graphite Pro typefaces.
    expect(AppTheme.fontFamily, 'Inter');
    expect(AppTheme.monoFamily, 'JetBrains Mono');
  });

  // Accessibility (a11y): every Graphite Pro theme must clear WCAG 2.1 contrast
  // in the four screens the app actually paints. Text uses AA for normal text
  // (>= 4.5:1); accent/status colors are treated as UI components / large text
  // (>= 3.0:1, WCAG 1.4.11). Kept as pure math over the palette tokens so a
  // regression in any single color fails loudly with the offending ratio.
  const palettes = <String, AppPalette>{
    'dark': AppPalette.dark,
    'light': AppPalette.light,
    'dim': AppPalette.dim,
    'oled': AppPalette.oled,
  };

  palettes.forEach((name, p) {
    test('WCAG: "$name" readable text meets AA (>= 4.5:1)', () {
      final surfaces = <String, Color>{
        'background': p.background,
        'surface': p.surface,
        'card': p.card,
      };
      final texts = <String, Color>{
        'textPrimary': p.textPrimary,
        'textBody': p.textBody,
        'textMuted': p.textMuted,
      };
      texts.forEach((tn, tc) {
        surfaces.forEach((sn, sc) {
          final r = _contrast(tc, sc);
          expect(
            r,
            greaterThanOrEqualTo(4.5),
            reason: '[$name] $tn on $sn is ${r.toStringAsFixed(2)}:1 (< 4.5 AA)',
          );
        });
      });
    });

    test('WCAG: "$name" accents/status meet UI contrast (>= 3.0:1)', () {
      // White (or onPrimary) labels sitting on the brand accent (buttons).
      final onPrimary = _contrast(p.onPrimary, p.primary);
      expect(
        onPrimary,
        greaterThanOrEqualTo(3.0),
        reason:
            '[$name] onPrimary on primary is ${onPrimary.toStringAsFixed(2)}:1',
      );
      final accents = <String, Color>{
        'primary': p.primary,
        'danger': p.danger,
        'error': p.error,
        'warning': p.warning,
        'success': p.success,
        'info': p.info,
      };
      final onSurfaces = <String, Color>{
        'background': p.background,
        'card': p.card,
      };
      accents.forEach((an, ac) {
        onSurfaces.forEach((sn, sc) {
          final r = _contrast(ac, sc);
          expect(
            r,
            greaterThanOrEqualTo(3.0),
            reason: '[$name] $an on $sn is ${r.toStringAsFixed(2)}:1 (< 3.0)',
          );
        });
      });
    });
  });
}

// ── WCAG 2.1 relative luminance + contrast ratio ────────────────────────────
double _linearize(double channel) => channel <= 0.03928
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _linearize(c.r) + 0.7152 * _linearize(c.g) + 0.0722 * _linearize(c.b);

double _contrast(Color fg, Color bg) {
  final l1 = _luminance(fg);
  final l2 = _luminance(bg);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}
