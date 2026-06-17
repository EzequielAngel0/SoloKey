import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_generator.freezed.dart';

@freezed
class PasswordConfig with _$PasswordConfig {
  const factory PasswordConfig({
    @Default(16) int length,
    @Default(true) bool useUppercase,
    @Default(true) bool useLowercase,
    @Default(true) bool useNumbers,
    @Default(true) bool useSymbols,
    @Default('!@#\$%^&*()-_=+[]{}|;:,.<>?') String symbolSet,
  }) = _PasswordConfig;
}

abstract final class PasswordGenerator {
  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numbers = '0123456789';

  static String generate(PasswordConfig config) {
    if (config.length < 4) throw ArgumentError('Minimum length is 4');

    final pool = StringBuffer();
    final requiredSets = <String>[];

    if (config.useLowercase) {
      pool.write(_lower);
      requiredSets.add(_lower);
    }
    if (config.useUppercase) {
      pool.write(_upper);
      requiredSets.add(_upper);
    }
    if (config.useNumbers) {
      pool.write(_numbers);
      requiredSets.add(_numbers);
    }
    if (config.useSymbols) {
      pool.write(config.symbolSet);
      requiredSets.add(config.symbolSet);
    }

    if (pool.isEmpty) throw ArgumentError('At least one character set required');

    final rng = Random.secure();
    final poolStr = pool.toString();

    // Fill every position randomly from the full pool — natural distribution.
    final chars = List<String>.generate(
      config.length,
      (_) => poolStr[rng.nextInt(poolStr.length)],
    );

    // Guarantee at least one char from each enabled charset by placing them
    // at random (non-repeating) positions within the generated password.
    final guaranteePositions = List<int>.generate(config.length, (i) => i)
      ..shuffle(rng);
    for (var i = 0; i < requiredSets.length && i < config.length; i++) {
      final charSet = requiredSets[i];
      chars[guaranteePositions[i]] = charSet[rng.nextInt(charSet.length)];
    }

    return chars.join();
  }

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{}|;:,.<>?]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.good;
    return PasswordStrength.strong;
  }
}

enum PasswordStrength { none, weak, fair, good, strong }
