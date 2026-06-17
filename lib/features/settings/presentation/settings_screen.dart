import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/injection.dart';
import '../../../core/infrastructure/security/app_lifecycle_observer.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../vault_access/application/vault_state_provider.dart';
import '../domain/entities/app_security_settings.dart';
import '../domain/repositories/i_settings_repository.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';

part 'settings_screen.g.dart';

// ── Settings provider ─────────────────────────────────────────────────────────

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSecuritySettings> build() async {
    return ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> save(AppSecuritySettings settings) async {
    final previous = state.valueOrNull;
    state = AsyncData(settings);
    await ref.read(settingsRepositoryProvider).saveSettings(settings);

    // ── Side-effect: Biometric key persistence ────────────────────────────
    if (previous != null &&
        previous.biometricEnabled != settings.biometricEnabled) {
      final storage = getIt<FlutterSecureStorage>();
      if (settings.biometricEnabled) {
        // Store current session key for future biometric unlocks
        final session = getIt<SessionManager>();
        final keyCopy = session.getKeyCopy();
        if (keyCopy != null) {
          await storage.write(
            key: 'bio_master_key',
            value: base64Encode(keyCopy),
          );
        }
      } else {
        // Wipe the stored biometric key
        await storage.delete(key: 'bio_master_key');
      }
    }

    // ── Side-effect: Screen protection toggle ────────────────────────────
    if (previous != null &&
        previous.obscureOnBackground != settings.obscureOnBackground) {
      await getIt<AppLifecycleObserver>().syncScreenProtection();
    }

    // ── Side-effect: Autostart (escritorio) ──────────────────────────────
    if (previous != null &&
        previous.autostartEnabled != settings.autostartEnabled &&
        !kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      try {
        if (settings.autostartEnabled) {
          await launchAtStartup.enable();
        } else {
          await launchAtStartup.disable();
        }
      } catch (_) {
        // No bloquear el guardado si el registro de autostart falla.
      }
    }
  }
}

@riverpod
ISettingsRepository settingsRepository(Ref ref) {
  throw UnimplementedError('Register via get_it override');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: const VaultAppBar(title: 'Ajustes de seguridad'),
      body: settingsAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: context.palette.accent)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => _SettingsBody(
          settings: settings,
          onUpdate: (s) =>
              ref.read(settingsNotifierProvider.notifier).save(s),
        ),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.settings, required this.onUpdate});

  final AppSecuritySettings settings;
  final ValueChanged<AppSecuritySettings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDesktop = !kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(label: 'Apariencia'),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _ThemeModeTile(
              current: settings.themeMode,
              onChanged: (key) => onUpdate(settings.copyWith(themeMode: key)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionHeader(label: 'Bloqueo automático'),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _SliderTile(
              icon: Icons.timer_rounded,
              label: 'Bloqueo por inactividad',
              valueLabel: '${settings.autoLockMinutes} min',
              value: settings.autoLockMinutes.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              onChanged: (v) => onUpdate(
                settings.copyWith(autoLockMinutes: v.round()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionHeader(label: 'Portapapeles'),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _SliderTile(
              icon: Icons.content_paste_off_rounded,
              label: 'Limpiar portapapeles',
              valueLabel: '${settings.clearClipboardSeconds}s',
              value: settings.clearClipboardSeconds.toDouble(),
              min: 10,
              max: 120,
              divisions: 22,
              onChanged: (v) => onUpdate(
                settings.copyWith(clearClipboardSeconds: v.round()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionHeader(label: 'Privacidad'),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _ToggleTile(
              icon: Icons.fingerprint_rounded,
              label: 'Desbloqueo biométrico',
              subtitle: 'Usa huella dactilar o rostro',
              value: settings.biometricEnabled,
              onChanged: (v) => onUpdate(
                settings.copyWith(biometricEnabled: v),
              ),
            ),
            const _Divider(),
            _ToggleTile(
              icon: Icons.visibility_off_rounded,
              label: 'Ocultar en segundo plano',
              subtitle: 'Aplica pantalla de privacidad al cambiar de app',
              value: settings.obscureOnBackground,
              onChanged: (v) => onUpdate(
                settings.copyWith(obscureOnBackground: v),
              ),
            ),
            if (isDesktop) ...[
              const _Divider(),
              _ToggleTile(
                icon: Icons.rocket_launch_rounded,
                label: 'Iniciar con el sistema',
                subtitle: 'Arranca minimizado en la bandeja al encender el equipo',
                value: settings.autostartEnabled,
                onChanged: (v) => onUpdate(
                  settings.copyWith(autostartEnabled: v),
                ),
              ),
            ],
            const _Divider(),
            _WipeAfterAttemptsTile(
              current: settings.wipeAfterFailedAttempts,
              onChanged: (n) =>
                  onUpdate(settings.copyWith(wipeAfterFailedAttempts: n)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _DataManagementSection(),
        const SizedBox(height: 32),
        _DangerZone(),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: context.palette.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: palette.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(
                    color: palette.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: palette.accent,
              thumbColor: palette.accent,
              inactiveTrackColor: palette.divider,
              overlayColor: palette.accent.withValues(alpha: 0.125),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: palette.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(color: palette.textPrimary, fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(
                        color: palette.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: palette.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      endIndent: 16,
      color: context.palette.divider,
    );
  }
}

/// Anti brute-force: wipe the vault after N failed unlock attempts (0 = off).
class _WipeAfterAttemptsTile extends StatelessWidget {
  const _WipeAfterAttemptsTile(
      {required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  static const _options = [0, 5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delete_forever_rounded, color: palette.danger, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Borrar bóveda tras intentos fallidos',
                        style:
                            TextStyle(color: palette.textPrimary, fontSize: 14)),
                    Text('Protección anti fuerza bruta (irreversible)',
                        style:
                            TextStyle(color: palette.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((n) {
              final selected = n == current;
              final color = n > 0 ? palette.danger : palette.textMuted;
              return GestureDetector(
                onTap: () => onChanged(n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.15)
                        : palette.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? color : palette.divider,
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Text(
                    n == 0 ? 'Desactivado' : '$n',
                    style: TextStyle(
                      color: selected ? color : palette.textMuted,
                      fontSize: 12.5,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.current, required this.onChanged});

  final String current;
  final ValueChanged<String> onChanged;

  /// Palette used to render each mode's live preview swatch.
  static AppPalette _previewPalette(AppThemeMode m) => switch (m) {
        AppThemeMode.light => AppPalette.light,
        AppThemeMode.dark => AppPalette.dark,
        AppThemeMode.dim => AppPalette.dim,
        AppThemeMode.oled => AppPalette.oled,
        AppThemeMode.system => AppPalette.dark,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, color: palette.accent, size: 20),
              const SizedBox(width: 12),
              Text(
                'Tema de la aplicación',
                style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: AppThemeMode.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final m = AppThemeMode.values[i];
                return _ThemeSwatch(
                  mode: m,
                  preview: _previewPalette(m),
                  selected: m.key == current,
                  accent: palette.accent,
                  onTap: () => onChanged(m.key),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A small live preview of a theme variant: shows the real background, a card
/// surface and an accent dot. `system` renders as a light/dark split.
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.mode,
    required this.preview,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final AppThemeMode mode;
  final AppPalette preview;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 66,
            height: 58,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? accent : palette.divider,
                width: selected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: mode == AppThemeMode.system
                      ? _buildSystemPreview()
                      : _buildPreview(preview),
                ),
                if (selected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration:
                          BoxDecoration(color: accent, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            mode.label == 'Seguir el sistema' ? 'Sistema' : mode.label,
            style: TextStyle(
              color: selected ? accent : palette.textMuted,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(AppPalette p) {
    return Container(
      color: p.background,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 6,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 40,
            height: 8,
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 30,
            height: 8,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPreview() {
    return Row(
      children: [
        Expanded(child: _buildPreview(AppPalette.light)),
        Expanded(child: _buildPreview(AppPalette.dark)),
      ],
    );
  }
}

// ── Data management section ───────────────────────────────────────────────────

class _DataManagementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(label: 'Gestión de datos'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (!ResponsiveLayout.isDesktop(context)) ...[
                ListTile(
                  leading: Icon(
                    Icons.sync_rounded,
                    color: palette.accent,
                  ),
                  title: Text(
                    'Sincronizar Computadora',
                    style: TextStyle(color: palette.textPrimary, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Vincula con SoloKey de escritorio',
                    style: TextStyle(color: palette.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: palette.textDisabled,
                  ),
                  onTap: () => context.push(AppRoutes.sync),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: palette.divider,
                ),
              ],
              ListTile(
                leading: Icon(
                  Icons.sync_alt_rounded,
                  color: palette.accent,
                ),
                title: Text(
                  'Exportar / Importar',
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                ),
                subtitle: Text(
                  'Haz backups cifrados de tu bóveda',
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: palette.textDisabled,
                ),
                onTap: () => context.push(AppRoutes.transfer),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: palette.divider,
              ),
              ListTile(
                leading: Icon(
                  Icons.auto_fix_high_rounded,
                  color: palette.accent,
                ),
                title: Text(
                  'Autocompletado del sistema',
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                ),
                subtitle: Text(
                  'Completa contraseñas en otras apps',
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: palette.textDisabled,
                ),
                onTap: () => context.push(AppRoutes.autofillOnboarding),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: palette.divider,
              ),
              ListTile(
                leading: Icon(
                  Icons.fingerprint_rounded,
                  color: palette.typePasskey,
                ),
                title: Text(
                  'Respaldo de Passkeys',
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                ),
                subtitle: Text(
                  'Guarda tus respaldos de passkey',
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: palette.textDisabled,
                ),
                onTap: () => context.push(AppRoutes.passkeys),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DangerZone extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(label: 'Zona peligrosa'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: palette.danger.withValues(alpha: 0.3)),
          ),
          child: ListTile(
            leading: Icon(Icons.lock_reset_rounded,
                color: palette.danger),
            title: Text('Bloquear ahora',
                style: TextStyle(color: palette.danger)),
            subtitle: Text('Cierra la sesión inmediatamente',
                style: TextStyle(color: palette.textMuted, fontSize: 12)),
            onTap: () {
              ref.read(vaultNotifierProvider.notifier).lock();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ),
      ],
    );
  }
}
