import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_colors.dart';
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
    (type: CredentialType.password,   label: 'Contraseña', icon: Icons.lock_rounded,          color: AppColors.typePassword),
    (type: CredentialType.apiKey,     label: 'API Key',    icon: Icons.key_rounded,           color: AppColors.typeApiKey),
    (type: CredentialType.secureNote, label: 'Nota',       icon: Icons.note_rounded,          color: AppColors.typeNote),
    (type: CredentialType.totp,       label: 'TOTP',       icon: Icons.access_time_rounded,   color: AppColors.typeTotp),
    (type: CredentialType.passkey,    label: 'Passkey',    icon: Icons.fingerprint_rounded,   color: AppColors.typePasskey),
    (type: CredentialType.sshKey,     label: 'Llave SSH',  icon: Icons.terminal_rounded,      color: AppColors.typeSshKey),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = _items[i];
          final isSelected = item.type == selected;
          final isDisabled = isEditing && item.type != selected;

          return GestureDetector(
            onTap: isDisabled ? null : () {
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
                    ? item.color.withValues(alpha: 0.15)
                    : isDisabled
                        ? AppColors.card.withValues(alpha: 0.5)
                        : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? item.color : Colors.transparent,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: item.color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      item.icon,
                      color: isSelected ? item.color : isDisabled ? AppColors.textDisabled : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? item.color : isDisabled ? AppColors.textDisabled : AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
