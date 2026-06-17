import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_palette.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.onAdd,
  });

  final String message;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo/SoloKey.png',
            height: 72,
            width: 72,
            color: palette.textEmpty,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyAddFirst,
            style: TextStyle(color: palette.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.emptyAddCredential),
          ),
        ],
      ),
    );
  }
}
