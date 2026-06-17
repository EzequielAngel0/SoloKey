import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/clipboard_countdown.dart';

import '../../../../features/password_generator/application/password_generator_provider.dart';
import '../../../../shared/widgets/password_strength_indicator.dart';
import '../../../../theme/app_palette.dart';

class PasswordGeneratorWidget extends ConsumerWidget {
  const PasswordGeneratorWidget({
    super.key,
    required this.onApplyPassword,
  });

  final ValueChanged<String> onApplyPassword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final config = ref.watch(passwordConfigNotifierProvider);
    final password = ref.watch(generatedPasswordNotifierProvider);
    final strength = ref.watch(passwordStrengthProvider);
    final notifier = ref.read(passwordConfigNotifierProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Generated Preview ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.cardDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    password,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: palette.accent),
                  onPressed: () => ref.read(generatedPasswordNotifierProvider.notifier).regenerate(),
                  tooltip: 'Regenerar',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PasswordStrengthIndicator(strength: strength),
          const SizedBox(height: 16),

          // ── Length slider ────────────────────────────────────────────
          Text(
            'Longitud: ${config.length}',
            style: TextStyle(
              color: palette.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: palette.accent,
              thumbColor: palette.accent,
              inactiveTrackColor: palette.divider,
              overlayColor: palette.accent.withValues(alpha: 0.12),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: config.length.toDouble(),
              min: 8,
              max: 64,
              divisions: 56,
              onChanged: (v) => notifier.setLength(v.round()),
            ),
          ),

          // ── Toggles ──────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'A-Z',
                selected: config.useUppercase,
                onSelected: (_) => notifier.toggleUppercase(),
              ),
              _FilterChip(
                label: 'a-z',
                selected: config.useLowercase,
                onSelected: (_) => notifier.toggleLowercase(),
              ),
              _FilterChip(
                label: '0-9',
                selected: config.useNumbers,
                onSelected: (_) => notifier.toggleNumbers(),
              ),
              _FilterChip(
                label: '!@#',
                selected: config.useSymbols,
                onSelected: (_) => notifier.toggleSymbols(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Apply Button ─────────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: () async {
              await showClipboardCountdownSnackBar(
                context: context,
                label: 'Contraseña generada',
                value: password,
              );
              onApplyPassword(password);
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Usar y Copiar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.accent,
              foregroundColor: palette.onPrimary,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: selected ? palette.onPrimary : palette.textMuted,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: palette.cardDark,
      selectedColor: palette.accent.withValues(alpha: 0.4),
      checkmarkColor: palette.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? palette.accent : Colors.transparent,
        ),
      ),
    );
  }
}
