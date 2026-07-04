import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// Flat, hairline-only progress indicator for short flows (Setup, Recovery).
///
/// Renders [totalSteps] segments; the first [currentStep] (1-based) are filled
/// with the primary token, the rest use the divider color. An optional [label]
/// (e.g. "Step 1 of 2 · Enter your code") is shown underneath. Graphite Pro:
/// no glow/gradient, just filled bars and a muted caption.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.label,
  });

  /// 1-based index of the active step.
  final int currentStep;
  final int totalSteps;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(totalSteps, (i) {
            final done = i < currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
                decoration: BoxDecoration(
                  color: done ? palette.primary : palette.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (label != null) ...[
          const SizedBox(height: 10),
          Text(
            label!,
            style: TextStyle(
              color: palette.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
