import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/password_generator.dart';

part 'password_generator_provider.g.dart';

/// Kept alive so the user's last generation preferences (length, charsets)
/// persist across opening the generator again during the session, instead of
/// resetting to defaults each time.
@Riverpod(keepAlive: true)
class PasswordConfigNotifier extends _$PasswordConfigNotifier {
  @override
  PasswordConfig build() => const PasswordConfig();

  void setLength(int length) => state = state.copyWith(length: length);
  void toggleUppercase() =>
      state = state.copyWith(useUppercase: !state.useUppercase);
  void toggleLowercase() =>
      state = state.copyWith(useLowercase: !state.useLowercase);
  void toggleNumbers() => state = state.copyWith(useNumbers: !state.useNumbers);
  void toggleSymbols() => state = state.copyWith(useSymbols: !state.useSymbols);
}

@riverpod
class GeneratedPasswordNotifier extends _$GeneratedPasswordNotifier {
  @override
  String build() {
    final config = ref.watch(passwordConfigNotifierProvider);
    return PasswordGenerator.generate(config);
  }

  void regenerate() {
    final config = ref.read(passwordConfigNotifierProvider);
    state = PasswordGenerator.generate(config);
  }
}

@riverpod
PasswordStrength passwordStrength(Ref ref) {
  final password = ref.watch(generatedPasswordNotifierProvider);
  return PasswordGenerator.evaluate(password);
}
