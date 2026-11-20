import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';
import 'search_and_filters.dart';

/// Escritorio en tres paneles (REDISENO_V2 §4): navegación, lista y detalle.
/// Todo sobre el mismo papel, separados por un borde fino; nada de colores
/// distintos por panel.
class DesktopPanes extends StatelessWidget {
  const DesktopPanes({
    super.key,
    required this.nav,
    required this.list,
    required this.detail,
    this.navWidth = 248,
    this.listWidth = 360,
  });

  final Widget nav;
  final Widget list;
  final Widget detail;
  final double navWidth;
  final double listWidth;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rule = VerticalDivider(width: 1, thickness: 1, color: p.rule);
    return ColoredBox(
      color: p.paper,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: navWidth, child: nav),
          rule,
          SizedBox(width: listWidth, child: list),
          rule,
          Expanded(child: detail),
        ],
      ),
    );
  }
}

/// Un renglón del panel de navegación: icono, texto, cuenta opcional y el
/// atajo a la vista. El activo, en tinta sobre fondo hundido.
class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.shortcut,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  /// Por ejemplo "Ctrl 1".
  final String? shortcut;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: 2,
        ),
        child: Material(
          color: selected ? p.inset : Colors.transparent,
          borderRadius: AppRadius.controlAll,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.controlAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.sm,
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: selected ? p.ink : p.inkSoft),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text(
                        label,
                        style: t.bodyMedium!.copyWith(
                          color: selected ? p.ink : p.inkSoft,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (count != null)
                      Text(
                        '$count',
                        style: t.labelMedium!.copyWith(color: p.inkFaint),
                      ),
                    if (shortcut != null) ...[
                      const SizedBox(width: AppSpace.sm),
                      KeyHint(shortcut!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
