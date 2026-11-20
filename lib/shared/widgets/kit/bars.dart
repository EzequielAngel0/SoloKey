import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';

/// Barra superior: sobre el papel, título a la izquierda, acciones como iconos
/// a la vista (con su texto en el tooltip) y un borde fino abajo. Crece con la
/// letra del sistema para que el título no se corte al 200 %.
class PaperTopBar extends StatelessWidget implements PreferredSizeWidget {
  const PaperTopBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.automaticallyImplyLeading = true,
    this.textScale = 1,
  });

  final String title;
  final List<Widget> actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  /// `MediaQuery.textScalerOf(context).scale(1)` de quien la usa, para que
  /// [preferredSize] crezca con la letra (un [Scaffold] lo pide sin contexto).
  final double textScale;

  static double heightFor(double scale) => 56 + (scale - 1).clamp(0, 2) * 28;

  @override
  Size get preferredSize => Size.fromHeight(heightFor(textScale));

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // AppBar topa la letra del título al 134 %; aquí sigue a la del sistema.
    final scaler = MediaQuery.textScalerOf(context);
    return AppBar(
      toolbarHeight: preferredSize.height,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textScaler: scaler,
      ),
      actions: [
        ...actions,
        const SizedBox(width: AppSpace.xs),
      ],
      shape: Border(bottom: BorderSide(color: p.rule)),
    );
  }
}

/// Un destino de la barra inferior.
class BarDestination {
  const BarDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Barra inferior del celular: **Bóveda · Seguridad · Ajustes** (REDISENO_V2
/// §4). Hoja con borde fino arriba; el destino activo va en tinta y negrita,
/// no en color. Sus etiquetas las topa Material al 130 %, como Android.
class PaperBottomBar extends StatelessWidget {
  const PaperBottomBar({
    super.key,
    required this.destinations,
    required this.index,
    required this.onSelect,
  });

  final List<BarDestination> destinations;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.rule)),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onSelect,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
