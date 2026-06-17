import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/infrastructure/clipboard/clipboard_service.dart';
import '../../../app/di/injection.dart';

class ClipboardCountdown extends StatefulWidget {
  const ClipboardCountdown({
    super.key,
    required this.label,
    required this.initialSeconds,
  });

  final String label;
  final int initialSeconds;

  @override
  State<ClipboardCountdown> createState() => _ClipboardCountdownState();
}

class _ClipboardCountdownState extends State<ClipboardCountdown> {
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${widget.label} copiado · se limpia en ${_secondsRemaining}s',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            value: _secondsRemaining / widget.initialSeconds,
            strokeWidth: 2.5,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            backgroundColor: Colors.white24,
          ),
        ),
      ],
    );
  }
}

/// Helper function to securely copy a value and show a ticking countdown SnackBar.
Future<void> showClipboardCountdownSnackBar({
  required BuildContext context,
  required String label,
  required String value,
}) async {
  final seconds = await getIt<ClipboardService>().copySecure(value);
  if (!context.mounted) return;

  // Clear any active SnackBars so they do not overlap
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: ClipboardCountdown(
        label: label,
        initialSeconds: seconds,
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: seconds),
      backgroundColor: const Color(0xFF6C63FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
