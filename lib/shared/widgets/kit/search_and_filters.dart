import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';

/// Búsqueda fija arriba de la bóveda. En escritorio muestra el atajo
/// ([shortcutHint], por ejemplo "Ctrl K") si el campo es ancho para la letra
/// actual; borrar queda a la vista.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.clearTooltip,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.shortcutHint,
    this.autofocus = false,
  });

  final String hint;
  final String clearTooltip;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String? shortcutHint;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _own;

  TextEditingController get _c =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, box) => ValueListenableBuilder<TextEditingValue>(
        valueListenable: _c,
        builder: (context, value, _) {
          // El atajo cede su lugar al texto cuando el campo es angosto.
          final hint = box.maxWidth >= scaler.scale(320)
              ? widget.shortcutHint
              : null;
          final Widget? suffix = value.text.isNotEmpty
              ? IconButton(
                  tooltip: widget.clearTooltip,
                  icon: Icon(Icons.close, color: p.ink),
                  onPressed: () {
                    _c.clear();
                    widget.onChanged?.call('');
                  },
                )
              : (hint == null
                    ? null
                    : Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpace.md,
                        ),
                        child: Center(widthFactor: 1, child: KeyHint(hint)),
                      ));
          return TextField(
            controller: _c,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(Icons.search, color: p.inkSoft),
              suffixIcon: suffix,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Atajo de teclado dibujado como una tecla ("Ctrl K").
class KeyHint extends StatelessWidget {
  const KeyHint(this.keys, {super.key});

  final String keys;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.sheet,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(color: p.ruleStrong),
      ),
      child: Text(
        keys,
        style: Theme.of(
          context,
        ).textTheme.labelSmall!.copyWith(color: p.inkSoft),
      ),
    );
  }
}

/// Filtro de la bóveda (todo, favoritos, un tipo, una carpeta). Seleccionado es
/// tinta llena; los demás, borde fino. Toque de 48.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = selected ? p.onInk : p.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpace.touch),
        child: Center(
          widthFactor: 1,
          child: Material(
            color: selected ? p.ink : p.sheet,
            shape: StadiumBorder(
              side: BorderSide(color: selected ? p.ink : p.ruleStrong),
            ),
            child: InkWell(
              onTap: onTap,
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md + 2,
                  vertical: AppSpace.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: fg),
                      const SizedBox(width: AppSpace.xs + 2),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge!.copyWith(color: fg),
                      ),
                    ),
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

/// Encabezado de una sección dentro de una pantalla o lista.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpace.lg, bottom: AppSpace.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: t.labelLarge!.copyWith(color: context.palette.inkSoft),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Lo que se ve cuando no hay nada (bóveda vacía, búsqueda sin resultados).
class EmptyNote extends StatelessWidget {
  const EmptyNote({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpace.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: p.inkSoft),
          const SizedBox(height: AppSpace.lg),
          Text(title, style: t.titleMedium, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              message!,
              style: t.bodyMedium!.copyWith(color: p.inkSoft),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: AppSpace.xl), action!],
        ],
      ),
    );
  }
}
