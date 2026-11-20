import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';

/// Qué tan fuerte habla un botón.
enum PaperButtonKind {
  /// La acción principal de la pantalla: tinta con letra de papel. Una por vista.
  primary,

  /// Acción secundaria: borde fino sobre la hoja.
  secondary,

  /// Acción discreta: solo texto.
  quiet,

  /// Lo que no se deshace (borrar, cerrar sesión en todos lados): rojo liso.
  destructive,
}

/// Botón de Tinta y papel. Alto mínimo de 48, esquinas de 12, sin sombra. Con la
/// letra al 200 % el texto baja de renglón en vez de cortarse.
class PaperButton extends StatelessWidget {
  const PaperButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.kind = PaperButtonKind.primary,
    this.expand = false,
    this.busy = false,
  });

  const PaperButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.busy = false,
  }) : kind = PaperButtonKind.secondary;

  const PaperButton.quiet({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.busy = false,
  }) : kind = PaperButtonKind.quiet;

  const PaperButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.busy = false,
  }) : kind = PaperButtonKind.destructive;

  final String label;

  /// `null` lo deshabilita.
  final VoidCallback? onPressed;
  final IconData? icon;
  final PaperButtonKind kind;

  /// Ocupa todo el ancho (formularios en el celular).
  final bool expand;

  /// Trabajando: muestra un indicador y no acepta toques.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final onTap = busy ? null : onPressed;
    final fg = switch (kind) {
      PaperButtonKind.primary => p.onInk,
      PaperButtonKind.destructive => p.onBreach,
      PaperButtonKind.secondary || PaperButtonKind.quiet => p.ink,
    };

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy)
          SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (busy || icon != null) const SizedBox(width: AppSpace.sm),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
            child: Text(label, textAlign: TextAlign.center, softWrap: true),
          ),
        ),
      ],
    );

    final Widget button = switch (kind) {
      PaperButtonKind.primary => FilledButton(onPressed: onTap, child: content),
      PaperButtonKind.secondary => OutlinedButton(
        onPressed: onTap,
        child: content,
      ),
      PaperButtonKind.quiet => TextButton(onPressed: onTap, child: content),
      PaperButtonKind.destructive => FilledButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.rule : p.breach,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.inkGhost : p.onBreach,
          ),
        ),
        child: content,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
