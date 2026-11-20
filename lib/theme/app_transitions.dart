import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Transición de pantalla de Tinta y papel: la hoja nueva aparece con un
/// fundido y sube apenas, en 200 ms. Sin escala ni rebote. Con "reducir
/// movimiento" del sistema, cambia sin animación.
class PaperPageTransition extends PageTransitionsBuilder {
  const PaperPageTransition();

  @override
  Duration get transitionDuration => AppMotion.standard;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;

    final curved = CurvedAnimation(parent: animation, curve: AppMotion.curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.015),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
