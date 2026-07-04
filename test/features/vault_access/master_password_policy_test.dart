import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault_access/domain/master_password_policy.dart';

void main() {
  group('MasterPasswordPolicy', () {
    test('a compliant password satisfies every requirement', () {
      const pwd = 'TestVault#2026';
      expect(MasterPasswordPolicy.hasMinLength(pwd), isTrue);
      expect(MasterPasswordPolicy.hasUppercase(pwd), isTrue);
      expect(MasterPasswordPolicy.hasNumber(pwd), isTrue);
      expect(MasterPasswordPolicy.hasSymbol(pwd), isTrue);
      expect(MasterPasswordPolicy.isValid(pwd), isTrue);
    });

    test('minimum length is 12 characters', () {
      expect(MasterPasswordPolicy.minLength, 12);
      expect(MasterPasswordPolicy.hasMinLength('Aa1!aaaaaaa'), isFalse); // 11
      expect(MasterPasswordPolicy.hasMinLength('Aa1!aaaaaaaa'), isTrue); // 12
    });

    test('isValid fails when any single requirement is missing', () {
      expect(MasterPasswordPolicy.isValid('short#1A'), isFalse); // too short
      expect(MasterPasswordPolicy.isValid('lowercase#123'), isFalse); // no upper
      expect(MasterPasswordPolicy.isValid('NoDigitsHere#!'), isFalse); // no number
      expect(MasterPasswordPolicy.isValid('NoSymbols12345'), isFalse); // no symbol
    });

    test('does not reject on a weaker rule than setup (>= 12, not 8)', () {
      // An 8-char password with all classes must still be rejected: the reset
      // flow must not downgrade below the setup policy.
      expect(MasterPasswordPolicy.isValid('Aa1!Aa1!'), isFalse);
    });
  });
}
