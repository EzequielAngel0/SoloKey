import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_palette.dart';
import '../../../../shared/widgets/secure_text_field.dart';
import 'password_generator_widget.dart';
import 'password_strength_meter.dart';

class PasswordRowWidget extends StatelessWidget {
  const PasswordRowWidget({
    super.key,
    required this.ctrl,
    required this.label,
    required this.showGenerator,
    required this.onToggleGenerator,
    this.validator,
    this.showStrength = false,
  });

  final TextEditingController ctrl;
  final String label;
  final bool showGenerator;
  final ValueChanged<bool> onToggleGenerator;
  final String? Function(String?)? validator;

  /// When true, a live strength meter is shown under the field (guidance only).
  final bool showStrength;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
                    ? palette.accent.withValues(alpha: 0.2)
                    : palette.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showGenerator
                      ? palette.accent.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Semantics(
                button: true,
                toggled: showGenerator,
                label: AppLocalizations.of(context).passwordRowGeneratorTooltip,
                child: IconButton(
                  icon: Icon(
                    Icons.auto_fix_high_rounded,
                    color: showGenerator ? palette.accent : palette.textMuted,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    FocusScope.of(context).unfocus();
                    onToggleGenerator(!showGenerator);
                  },
                  tooltip: AppLocalizations.of(
                    context,
                  ).passwordRowGeneratorTooltip,
                ),
              ),
            ),
          ],
        ),
        if (showStrength) PasswordStrengthMeter(controller: ctrl),
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
