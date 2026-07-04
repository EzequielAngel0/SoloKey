import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_palette.dart';
import '../../domain/entities/credential.dart';

class TypeSelectorPremium extends StatelessWidget {
  const TypeSelectorPremium({
    super.key,
    required this.selected,
    required this.onChanged,
    this.isEditing = false,
  });

  final CredentialType selected;
  final ValueChanged<CredentialType> onChanged;
  final bool isEditing;

  static const _items = [
    (type: CredentialType.password, icon: Icons.lock_rounded),
    (type: CredentialType.apiKey, icon: Icons.key_rounded),
    (type: CredentialType.secureNote, icon: Icons.note_rounded),
    (type: CredentialType.totp, icon: Icons.access_time_rounded),
    (type: CredentialType.passkey, icon: Icons.fingerprint_rounded),
    (type: CredentialType.sshKey, icon: Icons.terminal_rounded),
  ];

  static String _label(AppLocalizations l10n, CredentialType type) =>
      switch (type) {
        CredentialType.password => l10n.typePassword,
        CredentialType.apiKey => l10n.typeApiKey,
        CredentialType.secureNote => l10n.typeSelNote,
        CredentialType.totp => l10n.typeSelTotp,
        CredentialType.passkey => l10n.typeSelPasskey,
        CredentialType.sshKey => l10n.typeSshKey,
      };

  Color _typeColor(CredentialType type, AppPalette p) => switch (type) {
        CredentialType.password => p.typePassword,
        CredentialType.apiKey => p.typeApiKey,
        CredentialType.secureNote => p.typeNote,
        CredentialType.totp => p.typeTotp,
        CredentialType.passkey => p.typePasskey,
        CredentialType.sshKey => p.typeSshKey,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = _items[i];
          final color = _typeColor(item.type, palette);
          final isSelected = item.type == selected;
          final isDisabled = isEditing && item.type != selected;

          return Semantics(
            button: true,
            selected: isSelected,
            enabled: !isDisabled,
            label: _label(l10n, item.type),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: isDisabled
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onChanged(item.type);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: isSelected ? 100 : 72,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : isDisabled
                          ? palette.card.withValues(alpha: 0.5)
                          : palette.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : palette.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        item.icon,
                        color: isSelected ? color : isDisabled ? palette.textDisabled : palette.textMuted,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _label(l10n, item.type),
                      style: TextStyle(
                        color: isSelected ? color : isDisabled ? palette.textDisabled : palette.textMuted,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
