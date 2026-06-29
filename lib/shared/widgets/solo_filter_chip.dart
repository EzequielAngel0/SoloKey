import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';

/// A flat Graphite Pro pill chip used for vault filters (Todos · Favoritos ·
/// Contraseñas · TOTP · …). Selected = solid [AppPalette.primary]; unselected =
/// [AppPalette.surface] with a hairline border. No glow, no gradient.
class SoloFilterChip extends StatelessWidget {
  const SoloFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// Optional accent for the unselected icon/dot (e.g. a credential type color).
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = selected ? p.onPrimary : p.textBody;
    return Material(
      color: selected ? p.primary : p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.rPill),
        side: BorderSide(color: selected ? p.primary : p.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected ? p.onPrimary : (accent ?? p.textMuted),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal, scrollable row of [SoloFilterChip]s with consistent spacing.
class SoloFilterChipBar extends StatelessWidget {
  const SoloFilterChipBar({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (_, i) => Center(child: children[i]),
      ),
    );
  }
}
