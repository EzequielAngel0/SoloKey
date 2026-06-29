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
}
