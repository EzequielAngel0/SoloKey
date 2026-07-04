/// Single source of truth for the master-password complexity policy.
///
/// Pure and side-effect free so it can be unit-tested directly and reused from
/// both the initial Setup flow and the Recovery reset flow — a reset must not
/// let the user pick a weaker master password than the one required at setup.
class MasterPasswordPolicy {
  const MasterPasswordPolicy._();

  static const int minLength = 12;

  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _number = RegExp(r'[0-9]');
  static final RegExp _symbol = RegExp(r'[!@#$%^&*()\-_=+]');

  static bool hasMinLength(String value) => value.length >= minLength;
  static bool hasUppercase(String value) => _upper.hasMatch(value);
  static bool hasNumber(String value) => _number.hasMatch(value);
  static bool hasSymbol(String value) => _symbol.hasMatch(value);

  /// True when [value] satisfies every requirement.
  static bool isValid(String value) =>
      hasMinLength(value) &&
      hasUppercase(value) &&
      hasNumber(value) &&
      hasSymbol(value);
}
