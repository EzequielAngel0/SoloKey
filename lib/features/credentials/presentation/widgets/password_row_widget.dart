import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/widgets/secure_text_field.dart';
import 'password_generator_widget.dart';

class PasswordRowWidget extends StatelessWidget {
  const PasswordRowWidget({
    super.key,
    required this.ctrl,
    required this.label,
    required this.showGenerator,
    required this.onToggleGenerator,
    this.validator,
  });

  final TextEditingController ctrl;
  final String label;
  final bool showGenerator;
  final ValueChanged<bool> onToggleGenerator;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SecureTextField(
                controller: ctrl,
                label: label,
                validator: validator,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: showGenerator
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showGenerator
                      ? AppColors.accent.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.auto_fix_high_rounded,
                  color: showGenerator
                      ? AppColors.accent
                      : AppColors.textMuted,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  FocusScope.of(context).unfocus();
                  onToggleGenerator(!showGenerator);
                },
                tooltip: 'Generador de claves',
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          alignment: Alignment.topCenter,
          child: showGenerator
              ? PasswordGeneratorWidget(
                  onApplyPassword: (pass) {
                    ctrl.text = pass;
                    HapticFeedback.mediumImpact();
                    onToggleGenerator(false);
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
