import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';

/// Botón de copiar a la vista (nada escondido en menús). Al copiar, el icono
/// cambia a una palomita 1.5 s; sin vibración ni sonido (DEC-5).
class CopyButton extends StatefulWidget {
  const CopyButton({
    super.key,
    required this.tooltip,
    required this.onCopy,
    this.icon = Icons.content_copy_outlined,
  });

  /// Qué copia, dicho para el lector de pantalla ("Copiar contraseña").
  final String tooltip;
  final Future<void> Function() onCopy;
  final IconData icon;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await widget.onCopy();
    if (!mounted) return;
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: _copy,
      icon: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.quick),
        child: _copied
            ? Icon(Icons.check, key: const ValueKey(true), color: p.sound)
            : Icon(widget.icon, key: const ValueKey(false), color: p.ink),
      ),
    );
  }
}
