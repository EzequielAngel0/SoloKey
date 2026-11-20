import 'package:flutter/material.dart';

import '../../../features/credentials/domain/entities/credential.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';
import 'copy_button.dart';

/// Icono de cada tipo de credencial. **Los tipos van por icono, no por color**
/// (ADR-0013); un solo juego de iconos (contorno).
IconData credentialTypeIcon(CredentialType type) => switch (type) {
  CredentialType.password => Icons.key_outlined,
  CredentialType.apiKey => Icons.data_object_outlined,
  CredentialType.secureNote => Icons.sticky_note_2_outlined,
  CredentialType.totp => Icons.timer_outlined,
  CredentialType.passkey => Icons.fingerprint,
  CredentialType.sshKey => Icons.terminal_outlined,
};

/// Una copia rápida que la fila deja a la vista.
class QuickCopy {
  const QuickCopy({
    required this.tooltip,
    required this.onCopy,
    this.icon = Icons.content_copy_outlined,
  });

  /// "Copiar usuario", "Copiar contraseña", "Copiar código".
  final String tooltip;
  final Future<void> Function() onCopy;
  final IconData icon;
}

/// Fila de la bóveda: icono del tipo, nombre, usuario, estado y **copiar en un
/// toque** sin abrir nada (REDISENO_V2 §4). Con la letra grande o en una
/// pantalla angosta, los botones de copiar bajan a un segundo renglón en vez de
/// apretar el nombre.
class CredentialRow extends StatelessWidget {
  const CredentialRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.status,
    this.copies = const [],
    this.favorite = false,
    this.favoriteLabel,
    this.selected = false,
    this.onTap,
  });

  /// Normalmente [credentialTypeIcon].
  final IconData icon;
  final String title;

  /// Usuario o dato secundario.
  final String? subtitle;

  /// Una [StatePill], solo si hay algo que decir (débil, comprometida).
  final Widget? status;
  final List<QuickCopy> copies;
  final bool favorite;

  /// Texto para el lector de pantalla cuando es favorita.
  final String? favoriteLabel;

  /// Seleccionada en el panel de escritorio.
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final scale = MediaQuery.textScalerOf(context).scale(1);

    final mark = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: p.inset,
        borderRadius: AppRadius.controlAll,
      ),
      child: Icon(icon, color: p.ink, size: 22),
    );

    final names = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (favorite) ...[
              const SizedBox(width: AppSpace.xs),
              Icon(
                Icons.star,
                size: 16,
                color: p.ink,
                semanticLabel: favoriteLabel,
              ),
            ],
          ],
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: text.bodyMedium!.copyWith(color: p.inkSoft),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (status != null) ...[const SizedBox(height: AppSpace.xs), status!],
      ],
    );

    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in copies)
          CopyButton(tooltip: c.tooltip, onCopy: c.onCopy, icon: c.icon),
      ],
    );

    return Material(
      color: selected ? p.inset : Colors.transparent,
      borderRadius: AppRadius.controlAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.controlAll,
        child: LayoutBuilder(
          builder: (context, box) {
            final stack = scale >= 1.5 || box.maxWidth < 360;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md,
                vertical: AppSpace.sm,
              ),
              child: stack && copies.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            mark,
                            const SizedBox(width: AppSpace.md),
                            Expanded(child: names),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 40 + AppSpace.xs,
                          ),
                          child: buttons,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        mark,
                        const SizedBox(width: AppSpace.md),
                        Expanded(child: names),
                        buttons,
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
