import 'package:flutter/material.dart';

import '../../../../shared/widgets/kit/kit.dart';

/// Marco de las pantallas de acceso (primer uso, desbloqueo, recuperación).
///
/// Celular: el contenido a lo ancho, sobre el papel. Escritorio o tableta
/// (ancho de 600 o más): centrado sobre una hoja ([PaperCard]) con un ancho de
/// lectura. Siempre desplazable, para que aguante la letra al 200 %.
class AccessLayout extends StatelessWidget {
  const AccessLayout({super.key, required this.children, this.appBar});

  final List<Widget> children;
  final PreferredSizeWidget? appBar;

  static const double _maxWidth = 460;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 600;
            final column = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            );
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? AppSpace.xl : AppSpace.lg,
                      vertical: AppSpace.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _maxWidth),
                      child: wide
                          ? PaperCard(
                              padding: const EdgeInsets.all(AppSpace.xl),
                              child: column,
                            )
                          : column,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Encabezado de una pantalla de acceso: la marca, el paso (si hay) y el
/// título con su explicación.
class AccessHeader extends StatelessWidget {
  const AccessHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.step,
    this.showMark = true,
  });

  final String title;
  final String? subtitle;

  /// "Paso 1 de 3 · ...", ya traducido.
  final String? step;
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showMark) ...[
          const Center(child: SoloKeyMark(size: 64)),
          const SizedBox(height: AppSpace.xl),
        ],
        if (step != null) ...[
          Text(step!, style: t.labelLarge?.copyWith(color: p.inkSoft)),
          const SizedBox(height: AppSpace.sm),
        ],
        Semantics(
          header: true,
          child: Text(title, style: t.headlineLarge),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text(subtitle!, style: t.bodyLarge?.copyWith(color: p.inkSoft)),
        ],
      ],
    );
  }
}

/// El monograma de SoloKey (decorativo: el nombre lo dice el texto de al lado).
/// Lo redibuja B en DIS-4; aquí solo se coloca.
class SoloKeyMark extends StatelessWidget {
  const SoloKeyMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        'assets/logo/solokey_mark.png',
        height: size,
        width: size,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/logo/SoloKey.png',
          height: size,
          width: size,
        ),
      ),
    );
  }
}
