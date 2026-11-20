import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';

/// Tarjeta de Tinta y papel: una hoja sobre el papel, borde fino, esquinas de
/// 12 y sombra suave. Con [onTap] se puede tocar y enfocar con el teclado.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.lg),
    this.semanticLabel,
  });

  final Widget child;

  /// Encabezado opcional de la tarjeta.
  final String? title;

  /// Junto al encabezado (un botón discreto, una pastilla).
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    Widget body = Padding(
      padding: padding,
      child: title == null && trailing == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (title != null)
                      Expanded(child: Text(title!, style: text.titleMedium)),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                child,
              ],
            ),
    );

    if (onTap != null) {
      body = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardAll,
          child: body,
        ),
      );
    }

    return Semantics(
      container: true,
      label: semanticLabel,
      button: onTap != null,
      child: DecoratedBox(decoration: AppDepth.card(p), child: body),
    );
  }
}
