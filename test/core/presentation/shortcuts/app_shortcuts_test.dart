import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/presentation/shortcuts/app_shortcuts.dart';

void main() {
  group('ShortcutBinding', () {
    test('serialize orders modifiers then trigger', () {
      const b = ShortcutBinding(
        trigger: LogicalKeyboardKey.keyK,
        control: true,
        shift: true,
      );
      expect(b.serialize(), 'ctrl+shift+k');
    });

    test('tryParse round-trips the canonical form', () {
      const b = ShortcutBinding(
        trigger: LogicalKeyboardKey.keyK,
        control: true,
        shift: true,
        alt: true,
      );
      expect(ShortcutBinding.tryParse(b.serialize()), b);
    });

    test('tryParse tolerates platform aliases and spacing', () {
      final b = ShortcutBinding.tryParse(' Control + Cmd + N ');
      expect(b, isNotNull);
      expect(b!.control, isTrue);
      expect(b.meta, isTrue);
      expect(b.trigger, LogicalKeyboardKey.keyN);
    });

    test('tryParse returns null for null, empty or trigger-less input', () {
      expect(ShortcutBinding.tryParse(null), isNull);
      expect(ShortcutBinding.tryParse(''), isNull);
      expect(ShortcutBinding.tryParse('ctrl+shift'), isNull);
    });

    test('hasModifier reflects whether any modifier is set', () {
      expect(
        const ShortcutBinding(trigger: LogicalKeyboardKey.keyK).hasModifier,
        isFalse,
      );
      expect(
        const ShortcutBinding(trigger: LogicalKeyboardKey.keyK, alt: true)
            .hasModifier,
        isTrue,
      );
    });

    test('toActivator carries the modifier flags', () {
      const b = ShortcutBinding(
        trigger: LogicalKeyboardKey.keyL,
        control: true,
        meta: true,
      );
      final a = b.toActivator();
      expect(a.trigger, LogicalKeyboardKey.keyL);
      expect(a.control, isTrue);
      expect(a.meta, isTrue);
      expect(a.shift, isFalse);
    });

    test('equality is value-based', () {
      expect(
        const ShortcutBinding(trigger: LogicalKeyboardKey.keyK, control: true),
        const ShortcutBinding(trigger: LogicalKeyboardKey.keyK, control: true),
      );
      expect(
        const ShortcutBinding(trigger: LogicalKeyboardKey.keyK, control: true),
        isNot(const ShortcutBinding(
            trigger: LogicalKeyboardKey.keyK, shift: true)),
      );
    });
  });

  group('AppShortcut', () {
    test('defaults are Ctrl+K / Ctrl+N / Ctrl+E / Ctrl+L', () {
      expect(AppShortcut.commandPalette.defaultBinding.serialize(), 'ctrl+k');
      expect(AppShortcut.newCredential.defaultBinding.serialize(), 'ctrl+n');
      expect(AppShortcut.editCredential.defaultBinding.serialize(), 'ctrl+e');
      expect(AppShortcut.lock.defaultBinding.serialize(), 'ctrl+l');
    });

    test('resolve returns default when no override', () {
      expect(
        AppShortcut.lock.resolve(const {}),
        AppShortcut.lock.defaultBinding,
      );
    });

    test('resolve honours a valid override', () {
      final b = AppShortcut.lock.resolve({'lock': 'ctrl+alt+q'});
      expect(b.control, isTrue);
      expect(b.alt, isTrue);
      expect(b.trigger, LogicalKeyboardKey.keyQ);
    });

    test('resolve falls back to default on a malformed override', () {
      expect(
        AppShortcut.lock.resolve(const {'lock': 'garbage++'}),
        AppShortcut.lock.defaultBinding,
      );
    });
  });
}
