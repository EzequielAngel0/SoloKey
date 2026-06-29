import 'package:flutter/material.dart';

/// Custom page transition: slide from bottom + fade.
/// Applied globally via [ThemeData.pageTransitionsTheme].
class SlideUpFadeTransition extends PageTransitionsBuilder {
  const SlideUpFadeTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Graphite Pro motion: subtle, "pro" — not a show-off slide.
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);

    final secondaryFade = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
    );

    return FadeTransition(
      opacity: secondaryFade,
      child: SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      ),
    );
  }
}
