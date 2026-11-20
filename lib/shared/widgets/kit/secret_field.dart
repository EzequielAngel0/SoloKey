import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_tokens.dart';
import 'copy_button.dart';

/// Pesos de un secreto revelado: las letras normales, los números más
/// gruesos y los símbolos en medio. **Otro peso, no otro color** (REDISENO_V2
/// §3), en Atkinson Hyperlegible Mono para que l, I y 1, y 0 y O no se
/// confundan.
List<TextSpan> secretSpans(String value, TextStyle base) {
  FontWeight weightOf(int c) {
    if (c >= 0x30 && c <= 0x39) return FontWeight.w700; // 0-9
    final isLetter = (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
    if (isLetter || c > 0x7F) return FontWeight.w400;
    return FontWeight.w500; // símbolos y espacios
  }

  final spans = <TextSpan>[];
  final run = StringBuffer();
  FontWeight? current;
  for (final c in value.runes) {
    final w = weightOf(c);
    if (current != null && w != current) {
      spans.add(
        TextSpan(
          text: run.toString(),
          style: base.copyWith(fontWeight: current),
        ),
      );
      run.clear();
    }
    current = w;
    run.writeCharCode(c);
  }
  if (run.isNotEmpty) {
    spans.add(
      TextSpan(
        text: run.toString(),
        style: base.copyWith(fontWeight: current),
      ),
    );
  }
  return spans;
}

/// Controlador que dibuja el texto con los pesos de [secretSpans] cuando el
/// campo está revelado. Oculto, Flutter pinta los puntos de siempre.
class SecretTextController extends TextEditingController {
  SecretTextController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (value.composing.isValid && withComposing) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    return TextSpan(style: style, children: secretSpans(text, style!));
  }
}

/// Un secreto de solo lectura (detalle de una credencial). Oculto muestra diez
/// puntos siempre, para no delatar el largo.
class SecretText extends StatelessWidget {
  const SecretText({
    super.key,
    required this.value,
    required this.revealed,
    this.style,
  });

  final String value;
  final bool revealed;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = AppTheme.mono(
      style ?? Theme.of(context).textTheme.titleMedium,
    ).copyWith(fontWeight: FontWeight.w400);
    if (!revealed) {
      return Text('•' * 10, style: base, semanticsLabel: '');
    }
    return SelectableText.rich(TextSpan(children: secretSpans(value, base)));
  }
}

/// Campo para escribir un secreto: monoespaciado, con **mostrar** y (opcional)
/// **copiar** a la vista. Los textos llegan del llamador ya traducidos.
class SecretField extends StatefulWidget {
  const SecretField({
    super.key,
    required this.label,
    required this.revealTooltip,
    required this.hideTooltip,
    this.controller,
    this.hint,
    this.helper,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onCopy,
    this.copyTooltip,
    this.autofocus = false,
    this.enabled = true,
    this.textInputAction,
    this.autofillHints,
  }) : assert(onCopy == null || copyTooltip != null);

  final String label;
  final String revealTooltip;
  final String hideTooltip;

  /// Mejor un [SecretTextController] (pesos al revelar). Si es `null`, el campo
  /// crea uno.
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Future<void> Function()? onCopy;
  final String? copyTooltip;
  final bool autofocus;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<SecretField> createState() => _SecretFieldState();
}

class _SecretFieldState extends State<SecretField> {
  SecretTextController? _own;
  bool _revealed = false;

  TextEditingController get _controller =>
      widget.controller ?? (_own ??= SecretTextController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextFormField(
      controller: _controller,
      obscureText: !_revealed,
      obscuringCharacter: '•',
      enableSuggestions: false,
      autocorrect: false,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      keyboardType: TextInputType.visiblePassword,
      style: AppTheme.mono(Theme.of(context).textTheme.bodyLarge),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helper,
        suffixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpace.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: _revealed ? widget.hideTooltip : widget.revealTooltip,
                onPressed: () => setState(() => _revealed = !_revealed),
                icon: Icon(
                  _revealed
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: p.ink,
                ),
              ),
              if (widget.onCopy != null)
                CopyButton(
                  tooltip: widget.copyTooltip!,
                  onCopy: widget.onCopy!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
