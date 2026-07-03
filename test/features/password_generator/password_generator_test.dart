import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/password_generator/domain/password_generator.dart';

/// Zero-Print: `Random.secure()` is not seedable, so we never assert a fixed
/// string — only invariants (length, pool membership, per-charset guarantee,
/// uniqueness). Generated secrets are inspected structurally, never logged.
void main() {
  const lower = 'abcdefghijklmnopqrstuvwxyz';
  const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  const symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  bool anyFrom(String s, String set) => s.split('').any(set.contains);

  group('PasswordGenerator.generate', () {
    test('produces exactly the requested length', () {
      for (final len in [4, 8, 16, 32, 64, 128]) {
        final pw = PasswordGenerator.generate(PasswordConfig(length: len));
        expect(pw.length, len, reason: 'length $len');
      }
    });

    test('only emits characters from the enabled pool', () {
      final pw = PasswordGenerator.generate(const PasswordConfig(
        length: 40,
        useUppercase: false,
        useSymbols: false,
      ));
      const allowed = '$lower$numbers';
      expect(pw.split('').every(allowed.contains), isTrue);
      expect(anyFrom(pw, upper), isFalse);
      expect(anyFrom(pw, symbols), isFalse);
    });

    test('guarantees at least one char from every enabled charset', () {
      // 100 runs to make the probabilistic guarantee reliable.
      for (var i = 0; i < 100; i++) {
        final pw = PasswordGenerator.generate(const PasswordConfig(length: 8));
        expect(anyFrom(pw, lower), isTrue, reason: 'missing lower @ $i');
        expect(anyFrom(pw, upper), isTrue, reason: 'missing upper @ $i');
        expect(anyFrom(pw, numbers), isTrue, reason: 'missing digit @ $i');
        expect(anyFrom(pw, symbols), isTrue, reason: 'missing symbol @ $i');
      }
    });

    test('respects a custom symbol set', () {
      final pw = PasswordGenerator.generate(const PasswordConfig(
        length: 30,
        useUppercase: false,
        useLowercase: false,
        useNumbers: false,
        symbolSet: '#@',
      ));
      expect(pw.split('').every('#@'.contains), isTrue);
    });

    test('throws when length < 4', () {
      expect(
        () => PasswordGenerator.generate(const PasswordConfig(length: 3)),
        throwsArgumentError,
      );
    });

    test('throws when no charset is enabled (empty pool)', () {
      expect(
        () => PasswordGenerator.generate(const PasswordConfig(
          length: 12,
          useUppercase: false,
          useLowercase: false,
          useNumbers: false,
          useSymbols: false,
        )),
        throwsArgumentError,
      );
    });

    test('generates unique passwords across runs', () {
      final seen = <String>{};
      for (var i = 0; i < 50; i++) {
        seen.add(PasswordGenerator.generate(const PasswordConfig(length: 24)));
      }
      // 24-char secrets from a large pool must not collide.
      expect(seen.length, 50);
    });
  });

  group('PasswordGenerator.evaluate', () {
    test('empty password is none', () {
      expect(PasswordGenerator.evaluate(''), PasswordStrength.none);
    });

    test('short single-class password is weak', () {
      // len 4 (<8) + lowercase only → score 1 → weak.
      expect(PasswordGenerator.evaluate('abcd'), PasswordStrength.weak);
    });

    test('mid-length mixed password is fair', () {
      // 'Abcdef1' → len 7: len>=8? no. lower+upper+digit → score 3 → fair.
      expect(PasswordGenerator.evaluate('Abcdef1'), PasswordStrength.fair);
    });

    test('good sits in the 5-point band', () {
      // len 12 (>=8,>=12) + lower+upper+digit = score 5 → good.
      expect(PasswordGenerator.evaluate('Abcdefghij12'), PasswordStrength.good);
    });

    test('long password with all classes is strong', () {
      // len16 + lower+upper+digit+symbol = score 7 → strong.
      expect(
        PasswordGenerator.evaluate('Abcdefghij123!@#'),
        PasswordStrength.strong,
      );
    });

    test('strength is monotonic as complexity grows', () {
      final ladder = [
        PasswordGenerator.evaluate('ab'),
        PasswordGenerator.evaluate('abcdefgh'),
        PasswordGenerator.evaluate('Abcdefgh1'),
        PasswordGenerator.evaluate('Abcdefghijkl1!'),
      ].map((s) => s.index).toList();
      final sorted = [...ladder]..sort();
      expect(ladder, sorted);
    });
  });
}
