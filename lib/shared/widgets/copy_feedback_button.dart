import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// Animated copy button: shows a ripple pulse + checkmark for 1.5 s after copy.
class CopyFeedbackButton extends StatefulWidget {
  const CopyFeedbackButton({
    super.key,
    required this.onCopy,
    this.size = 18.0,
    this.color,
  });

  final Future<void> Function() onCopy;
  final double size;

  /// Idle icon color. Defaults to the theme's muted text color.
  final Color? color;

  @override
  State<CopyFeedbackButton> createState() => _CopyFeedbackButtonState();
}

class _CopyFeedbackButtonState extends State<CopyFeedbackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _ripple;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ripple = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_copied) return;
    await widget.onCopy();
    if (!mounted) return;
    setState(() => _copied = true);
    await _ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await _ctrl.reverse();
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final idleColor = widget.color ?? palette.textMuted;
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size + 12,
        height: widget.size + 12,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Ripple ring
                if (_copied)
                  Opacity(
                    opacity: (1 - _ripple.value).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1.0 + _ripple.value * 0.8,
                      child: Container(
                        width: widget.size + 8,
                        height: widget.size + 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: palette.success,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Icon
                Transform.scale(
                  scale: _copied ? _scale.value : 1.0,
                  child: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    color: _copied ? palette.success : idleColor,
                    size: widget.size,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
