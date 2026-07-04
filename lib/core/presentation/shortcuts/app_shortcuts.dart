import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A single keyboard combination (modifiers + a trigger key), decoupled from
/// Flutter's [SingleActivator] so it can be serialized to/from a canonical
/// string (e.g. `"ctrl+shift+k"`) and persisted in `AppSecuritySettings`.
///
/// Used to make the desktop shortcuts (command palette, new credential, lock)
/// user-remappable. Convert to a [SingleActivator] with [toActivator] for the
/// `CallbackShortcuts` map.
@immutable
class ShortcutBinding {
  const ShortcutBinding({
    required this.trigger,
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  final LogicalKeyboardKey trigger;
  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  /// A binding is only usable if it pairs a non-modifier key with at least one
  /// modifier — otherwise it would swallow plain typing.
  bool get hasModifier => control || shift || alt || meta;

  SingleActivator toActivator() => SingleActivator(
        trigger,
        control: control,
        shift: shift,
        alt: alt,
        meta: meta,
      );

  /// Canonical lowercase form, e.g. `"ctrl+shift+k"`. Stable across sessions.
  String serialize() {
    final parts = <String>[];
    if (control) parts.add('ctrl');
    if (shift) parts.add('shift');
    if (alt) parts.add('alt');
    if (meta) parts.add('meta');
    parts.add(_triggerToken(trigger));
    return parts.join('+');
  }

  /// Human-facing label, e.g. `"Ctrl + Shift + K"`.
  String get label {
    final parts = <String>[];
    if (control) parts.add('Ctrl');
    if (shift) parts.add('Shift');
    if (alt) parts.add('Alt');
    if (meta) parts.add('Meta');
    final t = trigger.keyLabel;
    parts.add(t.isNotEmpty ? t.toUpperCase() : 'Key');
    return parts.join(' + ');
  }

  static String _triggerToken(LogicalKeyboardKey k) {
    final label = k.keyLabel;
    if (label.isNotEmpty) return label.toLowerCase();
    return 'key${k.keyId}';
  }

  /// Every labeled logical key, indexed by its lowercase label. Lets [tryParse]
  /// turn `"k"` back into [LogicalKeyboardKey.keyK] without a hand-written table.
  static final Map<String, LogicalKeyboardKey> _labelToKey = {
    for (final k in LogicalKeyboardKey.knownLogicalKeys)
      if (k.keyLabel.isNotEmpty) k.keyLabel.toLowerCase(): k,
  };

  /// Parses a canonical string back to a binding, or `null` when malformed /
  /// missing a trigger key. Tolerant of platform aliases (`control`, `cmd`, …).
  static ShortcutBinding? tryParse(String? raw) {
    if (raw == null) return null;
    final tokens = raw
        .toLowerCase()
        .split('+')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;

    var control = false, shift = false, alt = false, meta = false;
    LogicalKeyboardKey? trigger;
    for (final t in tokens) {
      switch (t) {
        case 'ctrl' || 'control':
          control = true;
        case 'shift':
          shift = true;
        case 'alt' || 'option':
          alt = true;
        case 'meta' || 'cmd' || 'command' || 'win' || 'super':
          meta = true;
        default:
          trigger = _labelToKey[t] ??
              (t.startsWith('key')
                  ? LogicalKeyboardKey(int.tryParse(t.substring(3)) ?? 0)
                  : null);
      }
    }
    if (trigger == null || trigger.keyId == 0) return null;
    return ShortcutBinding(
      trigger: trigger,
      control: control,
      shift: shift,
      alt: alt,
      meta: meta,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShortcutBinding &&
      other.trigger == trigger &&
      other.control == control &&
      other.shift == shift &&
      other.alt == alt &&
      other.meta == meta;

  @override
  int get hashCode => Object.hash(trigger, control, shift, alt, meta);
}

/// The remappable desktop actions. Each has a stable [id] (the settings-map
/// key) and a [defaultBinding]. Human labels are resolved at the call site from
/// `AppLocalizations` so this stays free of UI/i18n dependencies.
enum AppShortcut {
  commandPalette(
    'command_palette',
    ShortcutBinding(trigger: LogicalKeyboardKey.keyK, control: true),
  ),
  newCredential(
    'new_credential',
    ShortcutBinding(trigger: LogicalKeyboardKey.keyN, control: true),
  ),
  editCredential(
    'edit_credential',
    ShortcutBinding(trigger: LogicalKeyboardKey.keyE, control: true),
  ),
  lock(
    'lock',
    ShortcutBinding(trigger: LogicalKeyboardKey.keyL, control: true),
  );

  const AppShortcut(this.id, this.defaultBinding);

  final String id;
  final ShortcutBinding defaultBinding;

  /// Effective binding for this action given the persisted [overrides] map:
  /// a valid override wins, otherwise the [defaultBinding].
  ShortcutBinding resolve(Map<String, String> overrides) =>
      ShortcutBinding.tryParse(overrides[id]) ?? defaultBinding;
}
