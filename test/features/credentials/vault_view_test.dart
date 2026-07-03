import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/vault_view_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';

Credential _c({
  required String id,
  required String title,
  CredentialType type = CredentialType.password,
  bool favorite = false,
  int sortOrder = 0,
  DateTime? updatedAt,
}) =>
    Credential(
      id: id,
      type: type,
      title: title,
      isFavorite: favorite,
      sortOrder: sortOrder,
      createdAt: DateTime(2020),
      updatedAt: updatedAt ?? DateTime(2020),
    );

void main() {
  group('matchesVaultFilter', () {
    final password = _c(id: '1', title: 'A', type: CredentialType.password);
    final totp = _c(id: '2', title: 'B', type: CredentialType.totp);
    final passkey = _c(id: '3', title: 'C', type: CredentialType.passkey);
    final ssh = _c(id: '4', title: 'D', type: CredentialType.sshKey);
    final fav = _c(id: '5', title: 'E', favorite: true);

    test('all matches everything', () {
      for (final c in [password, totp, passkey, ssh, fav]) {
        expect(matchesVaultFilter(c, VaultFilter.all), isTrue);
      }
    });

    test('favorites matches only favourites', () {
      expect(matchesVaultFilter(fav, VaultFilter.favorites), isTrue);
      expect(matchesVaultFilter(password, VaultFilter.favorites), isFalse);
    });

    test('type filters match their own type only', () {
      expect(matchesVaultFilter(password, VaultFilter.password), isTrue);
      expect(matchesVaultFilter(totp, VaultFilter.password), isFalse);
      expect(matchesVaultFilter(totp, VaultFilter.totp), isTrue);
      expect(matchesVaultFilter(passkey, VaultFilter.passkey), isTrue);
      expect(matchesVaultFilter(ssh, VaultFilter.ssh), isTrue);
      expect(matchesVaultFilter(password, VaultFilter.ssh), isFalse);
    });
  });

  group('sortCredentials', () {
    test('titleAsc sorts case-insensitively', () {
      final list = [
        _c(id: '1', title: 'banana'),
        _c(id: '2', title: 'Apple'),
        _c(id: '3', title: 'cherry'),
      ];
      final sorted = sortCredentials(list, VaultSort.titleAsc);
      expect(sorted.map((c) => c.title), ['Apple', 'banana', 'cherry']);
    });

    test('updatedDesc puts most-recently-updated first', () {
      final list = [
        _c(id: '1', title: 'old', updatedAt: DateTime(2021, 1, 1)),
        _c(id: '2', title: 'new', updatedAt: DateTime(2024, 6, 1)),
        _c(id: '3', title: 'mid', updatedAt: DateTime(2022, 3, 1)),
      ];
      final sorted = sortCredentials(list, VaultSort.updatedDesc);
      expect(sorted.map((c) => c.id), ['2', '3', '1']);
    });

    test('manual respects sortOrder, tie-breaking by title', () {
      final list = [
        _c(id: '1', title: 'Zeta', sortOrder: 2),
        _c(id: '2', title: 'beta', sortOrder: 0),
        _c(id: '3', title: 'alpha', sortOrder: 0),
      ];
      final sorted = sortCredentials(list, VaultSort.manual);
      // sortOrder 0 first (alpha before beta), then sortOrder 2.
      expect(sorted.map((c) => c.id), ['3', '2', '1']);
    });

    test('does not mutate the input list', () {
      final list = [
        _c(id: '1', title: 'b'),
        _c(id: '2', title: 'a'),
      ];
      final before = list.map((c) => c.id).toList();
      sortCredentials(list, VaultSort.titleAsc);
      expect(list.map((c) => c.id).toList(), before);
    });
  });
}
