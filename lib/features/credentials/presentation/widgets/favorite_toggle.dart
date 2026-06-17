import 'package:flutter/material.dart';
import '../../../../theme/app_palette.dart';

class FavoriteToggle extends StatelessWidget {
  const FavoriteToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedScale(
              scale: value ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                value ? Icons.star_rounded : Icons.star_border_rounded,
                color: value ? palette.warning : palette.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Marcar como favorita',
              style: TextStyle(color: palette.textPrimary, fontSize: 13),
            ),
            const Spacer(),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: palette.warning,
            ),
          ],
        ),
      ),
    );
  }
}
