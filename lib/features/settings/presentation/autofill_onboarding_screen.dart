import 'package:flutter/material.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/autofill_service.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';

/// Onboarding screen that guides the user through activating SoloKey
/// as the system Autofill provider in Android settings.
///
/// This screen is shown from Settings and checks the current state
/// on resume so it can update the UI if the user just enabled autofill.
class AutofillOnboardingScreen extends StatefulWidget {
  const AutofillOnboardingScreen({super.key});

  @override
  State<AutofillOnboardingScreen> createState() =>
      _AutofillOnboardingScreenState();
}

class _AutofillOnboardingScreenState extends State<AutofillOnboardingScreen>
    with WidgetsBindingObserver {
  final _service = getIt<AutofillSettingsService>();
  bool _isEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check when the user returns from the system settings page
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _loading = true);
    final enabled = await _service.isAutofillEnabled();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _openSettings() => _service.openAutofillSettings();

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: const VaultAppBar(title: 'Autocompletado'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status badge
            _StatusBadge(enabled: _isEnabled, loading: _loading),

            const SizedBox(height: 32),

            // Illustration
            _IllustrationBox(),

            const SizedBox(height: 32),

            // Title
            Text(
              _isEnabled
                  ? '¡SoloKey está activo!'
                  : 'Activa el autocompletado',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              _isEnabled
                  ? 'SoloKey completará automáticamente tus contraseñas en\n'
                    'cualquier app o navegador de tu dispositivo.'
                  : 'Permite que SoloKey complete tus contraseñas\n'
                    'automáticamente en apps y navegadores.',
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (!_isEnabled) ...[
              const SizedBox(height: 40),
              const _StepList(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _openSettings,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Abrir ajustes de Autocompletado'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: palette.accent,
                  foregroundColor: palette.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _checkStatus,
                child: Text(
                  'Ya lo activé, verificar estado',
                  style: TextStyle(color: palette.textMuted),
                ),
              ),
            ],

            if (_isEnabled) ...[
              const SizedBox(height: 32),
              const _FeatureChip(
                icon: Icons.bolt_rounded,
                label: 'Detección automática de formularios de login',
              ),
              const SizedBox(height: 10),
              const _FeatureChip(
                icon: Icons.lock_rounded,
                label: 'Solo funciona con la bóveda desbloqueada',
              ),
              const SizedBox(height: 10),
              const _FeatureChip(
                icon: Icons.shield_rounded,
                label: 'Credenciales nunca expuestas al SO',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.enabled, required this.loading});
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (loading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.accent,
          ),
        ),
      );
    }
    final color = enabled ? palette.success : palette.danger;
    final label = enabled ? 'Activo' : 'Inactivo';
    final icon  = enabled ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.card, palette.drawer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative circles
          Positioned(
            right: 30,
            top: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 15,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: palette.success.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main icon
          Icon(
            Icons.auto_fix_high_rounded,
            size: 64,
            color: palette.accent,
          ),
        ],
      ),
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final steps = [
      (
        '1',
        'Toca "Abrir ajustes de Autocompletado"',
        'Se abrirá la configuración del sistema',
      ),
      (
        '2',
        'Selecciona "SoloKey" como proveedor',
        'Busca SoloKey en la lista de apps',
      ),
      (
        '3',
        'Confirma y regresa a la app',
        'El autocompletado quedará activado',
      ),
    ];

    return Column(
      children: steps.map((s) {
        final (num, title, sub) = s;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  num,
                  style: TextStyle(
                    color: palette.onPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      sub,
                      style: TextStyle(
                        color: palette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
