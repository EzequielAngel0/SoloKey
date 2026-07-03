import 'package:flutter/material.dart';

import '../../../../features/password_generator/domain/password_generator.dart';
import '../../../../shared/widgets/password_strength_indicator.dart';

/// Live strength meter that reacts to typing in [controller]. It's guidance,
/// not validation — nothing blocks saving a weak password. Hidden while empty.
class PasswordStrengthMeter extends StatefulWidget {
  const PasswordStrengthMeter({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PasswordStrengthMeter> createState() => _PasswordStrengthMeterState();
}

class _PasswordStrengthMeterState extends State<PasswordStrengthMeter> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: PasswordStrengthIndicator(
        strength: PasswordGenerator.evaluate(text),
      ),
    );
  }
}
