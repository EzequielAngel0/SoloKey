import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/presentation/shortcuts/app_shortcuts.dart';
import '../../../core/infrastructure/security/app_lifecycle_observer.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../../../core/services/scheduled_backup_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/language_mode.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/detail_group.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../vault_access/application/vault_state_provider.dart';
import '../domain/entities/app_security_settings.dart';
import '../domain/repositories/i_settings_repository.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ui_density.dart';

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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VaultAppBar(title: AppLocalizations.of(context).navSettings),
      body: const SettingsView(),
    );
  }
}

/// Body-only settings content (no [Scaffold]/[AppBar]). Used standalone in
/// [SettingsScreen] (desktop / pushed route) and embedded as the mobile
/// "Ajustes" navigation destination.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return settingsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: context.palette.accent)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (settings) => _SettingsBody(
        settings: settings,
        onUpdate: (s) => ref.read(settingsNotifierProvider.notifier).save(s),
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
    final l10n = AppLocalizations.of(context);
    final isDesktop = !kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // ── Apariencia ──────────────────────────────────────────────────────
        SectionHeader(text: l10n.settingsSectionAppearance),
        DetailGroup(
          children: [
            _ThemeModeTile(
              current: settings.themeMode,
              onChanged: (key) => onUpdate(settings.copyWith(themeMode: key)),
            ),
            _LanguageModeTile(
              current: settings.locale,
              onChanged: (key) => onUpdate(settings.copyWith(locale: key)),
            ),
            _DensityTile(
              current: settings.uiDensity,
              onChanged: (key) => onUpdate(settings.copyWith(uiDensity: key)),
            ),
          ],
        ),
        // ── Seguridad ───────────────────────────────────────────────────────
        SectionHeader(text: l10n.settingsSectionSecurity),
        DetailGroup(
          children: [
            _SliderTile(
              icon: Icons.timer_rounded,
              label: l10n.settingsAutoLockLabel,
              valueLabel: l10n.settingsAutoLockValue(settings.autoLockMinutes),
              value: settings.autoLockMinutes.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              onChanged: (v) => onUpdate(
                settings.copyWith(autoLockMinutes: v.round()),
              ),
            ),
            _SliderTile(
              icon: Icons.content_paste_off_rounded,
              label: l10n.settingsClearClipboardLabel,
              valueLabel: l10n
                  .settingsClearClipboardValue(settings.clearClipboardSeconds),
              value: settings.clearClipboardSeconds.toDouble(),
              min: 10,
              max: 120,
              divisions: 22,
              onChanged: (v) => onUpdate(
                settings.copyWith(clearClipboardSeconds: v.round()),
              ),
            ),
            _ToggleTile(
              icon: Icons.fingerprint_rounded,
              label: l10n.settingsBiometricLabel,
              subtitle: l10n.settingsBiometricSubtitle,
              value: settings.biometricEnabled,
              onChanged: (v) => onUpdate(
                settings.copyWith(biometricEnabled: v),
              ),
            ),
            _ToggleTile(
              icon: Icons.visibility_off_rounded,
              label: l10n.settingsObscureLabel,
              subtitle: l10n.settingsObscureSubtitle,
              value: settings.obscureOnBackground,
              onChanged: (v) => onUpdate(
                settings.copyWith(obscureOnBackground: v),
              ),
            ),
            if (isDesktop)
              _ToggleTile(
                icon: Icons.rocket_launch_rounded,
                label: l10n.settingsAutostartLabel,
                subtitle: l10n.settingsAutostartSubtitle,
                value: settings.autostartEnabled,
                onChanged: (v) => onUpdate(
                  settings.copyWith(autostartEnabled: v),
                ),
              ),
            _WipeAfterAttemptsTile(
              current: settings.wipeAfterFailedAttempts,
              onChanged: (n) =>
                  onUpdate(settings.copyWith(wipeAfterFailedAttempts: n)),
            ),
          ],
        ),
        // ── Atajos de teclado (solo escritorio) ─────────────────────────────
        if (isDesktop)
          _ShortcutsSection(
            overrides: settings.shortcutOverrides,
            onChanged: (m) =>
                onUpdate(settings.copyWith(shortcutOverrides: m)),
          ),
        // ── Quick-Fill (solo escritorio) ────────────────────────────────────
        if (isDesktop) ...[
          SectionHeader(text: l10n.settingsSectionQuickFill),
          const DetailGroup(children: [_QuickFillInfoTile()]),
        ],
        // ── Datos ───────────────────────────────────────────────────────────
        _DataManagementSection(),
        // ── Acerca de ───────────────────────────────────────────────────────
        const _AboutSection(),
        // ── Zona peligrosa ──────────────────────────────────────────────────
        _DangerZone(),
      ],
    );
  }
}

/// Desktop-only card explaining the global Quick-Fill hotkey. Desktop OSes have
/// no system autofill, so SoloKey offers a hotkey-driven copy-to-clipboard flow.
class _QuickFillInfoTile extends StatelessWidget {
  const _QuickFillInfoTile();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: palette.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.settingsQuickFillDescription,
                  style: TextStyle(color: palette.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.cardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: palette.divider),
                ),
                child: Text(
                  'Ctrl + Shift + L',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.quickFill),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(l10n.settingsQuickFillTryNow),
                style: TextButton.styleFrom(foregroundColor: palette.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Desktop-only section listing the remappable keyboard shortcuts. Each row
/// shows the action and its current combination; tapping opens a capture
/// dialog. A header action resets every shortcut to its default.
class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection({required this.overrides, required this.onChanged});

  final Map<String, String> overrides;
  final ValueChanged<Map<String, String>> onChanged;

  static String _label(AppLocalizations l10n, AppShortcut s) => switch (s) {
        AppShortcut.commandPalette => l10n.shortcutCommandPalette,
        AppShortcut.newCredential => l10n.shortcutNewCredential,
        AppShortcut.lock => l10n.shortcutLock,
      };

  Future<void> _edit(BuildContext context, AppShortcut shortcut) async {
    final l10n = AppLocalizations.of(context);
    final captured = await showDialog<ShortcutBinding>(
      context: context,
      builder: (_) => _ShortcutCaptureDialog(
        title: _label(l10n, shortcut),
        current: shortcut.resolve(overrides),
      ),
    );
    if (captured == null || !context.mounted) return;

    // Reject a combination already bound to a different action.
    final conflict = AppShortcut.values.any(
      (other) => other != shortcut && other.resolve(overrides) == captured,
    );
    if (conflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.shortcutConflict)),
      );
      return;
    }
    onChanged({...overrides, shortcut.id: captured.serialize()});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final isDefault = overrides.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          text: l10n.settingsSectionShortcuts,
          trailing: TextButton(
            onPressed: isDefault ? null : () => onChanged(const {}),
            style: TextButton.styleFrom(
              foregroundColor: palette.accent,
              disabledForegroundColor: palette.textDisabled,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.shortcutReset, style: const TextStyle(fontSize: 12)),
          ),
        ),
        DetailGroup(
          children: [
            for (final s in AppShortcut.values)
              _ShortcutRow(
                label: _label(l10n, s),
                binding: s.resolve(overrides),
                onTap: () => _edit(context, s),
              ),
          ],
        ),
      ],
    );
  }
}

/// A single shortcut row: action label on the left, a kbd-style chip with the
/// current combination and an edit icon on the right.
class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.label,
    required this.binding,
    required this.onTap,
  });

  final String label;
  final ShortcutBinding binding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.keyboard_rounded, color: palette.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: palette.textPrimary, fontSize: 14),
              ),
            ),
            _KbdChip(text: binding.label),
            const SizedBox(width: 8),
            Icon(Icons.edit_rounded, color: palette.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Monospace "keycap" chip used to render a shortcut combination.
class _KbdChip extends StatelessWidget {
  const _KbdChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: palette.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.divider),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.monoFamily,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Modal that records a new key combination. Autofocuses a [Focus] and captures
/// the first non-modifier key pressed while a modifier is held. Escape cancels.
class _ShortcutCaptureDialog extends StatefulWidget {
  const _ShortcutCaptureDialog({required this.title, required this.current});

  final String title;
  final ShortcutBinding current;

  @override
  State<_ShortcutCaptureDialog> createState() => _ShortcutCaptureDialogState();
}

class _ShortcutCaptureDialogState extends State<_ShortcutCaptureDialog> {
  static final Set<LogicalKeyboardKey> _modifiers = {
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  };

  ShortcutBinding? _captured;
  bool _needsModifier = false;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.handled;
    final key = event.logicalKey;
    // Escape cancels without saving.
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    // Wait for a real (non-modifier) key while modifiers are held.
    if (_modifiers.contains(key)) return KeyEventResult.handled;

    final keyboard = HardwareKeyboard.instance;
    final binding = ShortcutBinding(
      trigger: key,
      control: keyboard.isControlPressed,
      shift: keyboard.isShiftPressed,
      alt: keyboard.isAltPressed,
      meta: keyboard.isMetaPressed,
    );
    setState(() {
      if (binding.hasModifier) {
        _captured = binding;
        _needsModifier = false;
      } else {
        _captured = null;
        _needsModifier = true;
      }
    });
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final preview = _captured ?? widget.current;
    return AlertDialog(
      title: Text(l10n.shortcutEditTitle),
      content: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _KbdChip(text: preview.label),
            const SizedBox(height: 16),
            Text(
              _needsModifier
                  ? l10n.shortcutNeedsModifier
                  : l10n.shortcutCapturePrompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _needsModifier ? palette.danger : palette.textDisabled,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: _captured == null
              ? null
              : () => Navigator.of(context).pop(_captured),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// Language selector: three pills (system / Spanish / English) persisted in
/// `AppSecuritySettings.locale`. Mirrors the visual weight of [_ThemeModeTile].
class _LanguageModeTile extends StatelessWidget {
  const _LanguageModeTile({required this.current, required this.onChanged});

  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    String labelFor(LanguageMode m) => switch (m) {
          LanguageMode.system => l10n.languageSystem,
          LanguageMode.spanish => l10n.languageSpanish,
          LanguageMode.english => l10n.languageEnglish,
        };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate_rounded, color: palette.accent, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.settingsSectionLanguage,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: LanguageMode.values.map((m) {
              final selected = m.key == current;
              return GestureDetector(
                onTap: () => onChanged(m.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? palette.accent.withValues(alpha: 0.15)
                        : palette.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? palette.accent : palette.divider,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    labelFor(m),
                    style: TextStyle(
                      color: selected ? palette.accent : palette.textMuted,
                      fontSize: 13,
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

/// UI density selector: two pills (comfortable / compact) persisted in
/// `AppSecuritySettings.uiDensity` and applied as `VisualDensity` in `app.dart`.
class _DensityTile extends StatelessWidget {
  const _DensityTile({required this.current, required this.onChanged});

  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    String labelFor(UiDensity d) => switch (d) {
          UiDensity.comfortable => l10n.densityComfortable,
          UiDensity.compact => l10n.densityCompact,
        };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.density_medium_rounded,
                  color: palette.accent, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.settingsDensityTitle,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: UiDensity.values.map((d) {
              final selected = d.key == current;
              return GestureDetector(
                onTap: () => onChanged(d.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? palette.accent.withValues(alpha: 0.15)
                        : palette.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? palette.accent : palette.divider,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(d.icon,
                          size: 16,
                          color:
                              selected ? palette.accent : palette.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        labelFor(d),
                        style: TextStyle(
                          color: selected ? palette.accent : palette.textMuted,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
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
    final l10n = AppLocalizations.of(context);
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
                    Text(l10n.settingsWipeTitle,
                        style:
                            TextStyle(color: palette.textPrimary, fontSize: 14)),
                    Text(l10n.settingsWipeSubtitle,
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
                    n == 0 ? l10n.commonDisabled : '$n',
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

  static String _themeLabel(AppLocalizations l10n, AppThemeMode m) =>
      switch (m) {
        AppThemeMode.system => l10n.themeSystem,
        AppThemeMode.light => l10n.themeLight,
        AppThemeMode.dark => l10n.themeDark,
        AppThemeMode.dim => l10n.themeDim,
        AppThemeMode.oled => l10n.themeOled,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
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
                l10n.settingsThemeTitle,
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
                  label: _themeLabel(l10n, m),
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
    required this.label,
    required this.preview,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final AppThemeMode mode;
  final String label;
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
            label,
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(text: l10n.settingsSectionData),
        DetailGroup(
          children: [
            if (!ResponsiveLayout.isDesktop(context))
              _DataRow(
                icon: Icons.sync_rounded,
                iconColor: palette.accent,
                title: l10n.settingsSyncComputerTitle,
                subtitle: l10n.settingsSyncComputerSubtitle,
                onTap: () => context.push(AppRoutes.sync),
              ),
            _DataRow(
              icon: Icons.sync_alt_rounded,
              iconColor: palette.accent,
              title: l10n.settingsExportImportTitle,
              subtitle: l10n.settingsExportImportSubtitle,
              onTap: () => context.push(AppRoutes.transfer),
            ),
            _DataRow(
              icon: Icons.auto_fix_high_rounded,
              iconColor: palette.accent,
              title: l10n.settingsAutofillTitle,
              subtitle: l10n.settingsAutofillSubtitle,
              onTap: () => context.push(AppRoutes.autofillOnboarding),
            ),
            _DataRow(
              icon: Icons.fingerprint_rounded,
              iconColor: palette.typePasskey,
              title: l10n.settingsPasskeysTitle,
              subtitle: l10n.settingsPasskeysSubtitle,
              onTap: () => context.push(AppRoutes.passkeys),
            ),
            const _ScheduledBackupTile(),
          ],
        ),
      ],
    );
  }
}

/// A navigation row (icon · title · subtitle · chevron) used inside the Data
/// section's [DetailGroup]. Kept local to Settings — it wraps [ListTile] with
/// the muted subtitle styling the screen uses everywhere.
class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title,
          style: TextStyle(color: palette.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle,
          style: TextStyle(color: palette.textMuted, fontSize: 12)),
      trailing:
          Icon(Icons.chevron_right_rounded, color: palette.textDisabled),
      onTap: onTap,
    );
  }
}

/// Configures automatic encrypted backups (interval + destination folder +
/// backup password). Backup password is kept in the Keystore, not in settings.
class _ScheduledBackupTile extends ConsumerWidget {
  const _ScheduledBackupTile();

  static const _intervals = [0, 1, 7, 30];

  String _intervalLabel(AppLocalizations l10n, int days) => switch (days) {
        0 => l10n.commonDisabled,
        1 => l10n.settingsBackupDaily,
        7 => l10n.settingsBackupWeekly,
        30 => l10n.settingsBackupMonthly,
        _ => l10n.settingsBackupEveryNDays(days),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsNotifierProvider).valueOrNull;
    final interval = settings?.scheduledBackupIntervalDays ?? 0;
    final dir = settings?.backupDirectory;
    final subtitle = interval <= 0
        ? l10n.commonDisabled
        : '${_intervalLabel(l10n, interval)} → ${dir == null ? l10n.settingsBackupNoFolder : dir.split(RegExp(r'[\\/]')).last}';
    return ListTile(
      leading: Icon(Icons.backup_rounded, color: palette.accent),
      title: Text(l10n.settingsBackupTitle,
          style: TextStyle(color: palette.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle,
          style: TextStyle(color: palette.textMuted, fontSize: 12),
          overflow: TextOverflow.ellipsis),
      trailing:
          Icon(Icons.chevron_right_rounded, color: palette.textDisabled),
      onTap: () => _showConfig(context, ref, settings),
    );
  }

  Future<void> _showConfig(
      BuildContext context, WidgetRef ref, AppSecuritySettings? settings) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    var interval = settings?.scheduledBackupIntervalDays ?? 0;
    var dir = settings?.backupDirectory;
    final pwdCtrl = TextEditingController();
    final hasPwd =
        await getIt<ScheduledBackupService>().hasBackupPassword();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setLocal) => AlertDialog(
          backgroundColor: palette.drawer,
          title: Text(l10n.settingsBackupTitle,
              style: TextStyle(color: palette.textPrimary, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsBackupFrequency,
                    style: TextStyle(color: palette.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _intervals.map((n) {
                    final sel = n == interval;
                    return GestureDetector(
                      onTap: () => setLocal(() => interval = n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel
                              ? palette.accent.withValues(alpha: 0.15)
                              : palette.surface,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              color: sel ? palette.accent : palette.divider),
                        ),
                        child: Text(_intervalLabel(l10n, n),
                            style: TextStyle(
                                color: sel ? palette.accent : palette.textMuted,
                                fontSize: 12)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked =
                        await FilePicker.platform.getDirectoryPath();
                    if (picked != null) setLocal(() => dir = picked);
                  },
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: Text(
                    dir == null ? l10n.settingsBackupChooseFolder : dir!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pwdCtrl,
                  obscureText: true,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: hasPwd
                        ? l10n.settingsBackupPasswordKeep
                        : l10n.settingsBackupPassword,
                    labelStyle: TextStyle(color: palette.textMuted),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () async {
                final svc = getIt<ScheduledBackupService>();
                if (pwdCtrl.text.isNotEmpty) {
                  await svc.setBackupPassword(pwdCtrl.text);
                }
                final base = settings ?? AppSecuritySettings.defaults();
                await ref.read(settingsNotifierProvider.notifier).save(
                      base.copyWith(
                        scheduledBackupIntervalDays: interval,
                        backupDirectory: dir,
                      ),
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                // Dispara un backup de inmediato si ya esta todo configurado.
                await svc.runIfDue();
              },
              child: Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// "About" section: app name, version and short tagline. Read-only.
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(text: l10n.settingsSectionAbout),
        DetailGroup(
          children: [
            ListTile(
              leading: Icon(Icons.shield_rounded, color: palette.accent),
              title: Text('SoloKey',
                  style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.settingsAboutTagline,
                  style: TextStyle(color: palette.textMuted, fontSize: 12)),
              trailing: Text(
                '${l10n.settingsVersionLabel} ${AppConstants.appVersion}',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontFamily: AppTheme.monoFamily,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DangerZone extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(text: l10n.settingsSectionDanger),
        Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(AppTheme.rCard),
            border: Border.all(
                color: palette.danger.withValues(alpha: 0.3)),
          ),
          child: ListTile(
            leading: Icon(Icons.lock_reset_rounded,
                color: palette.danger),
            title: Text(l10n.settingsLockNowTitle,
                style: TextStyle(color: palette.danger)),
            subtitle: Text(l10n.settingsLockNowSubtitle,
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
