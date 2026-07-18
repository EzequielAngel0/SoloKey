import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/secure_files/application/secure_files_view.dart';
import 'package:password_manager/features/secure_files/domain/entities/secure_file.dart';

SecureFile _f(
  String id, {
  String name = 'file.txt',
  String? note,
  String? mime,
  int size = 10,
  int createdAt = 0,
  bool fav = false,
}) =>
    SecureFile(
      id: id,
      name: name,
      sizeBytes: size,
      storedFileName: '$id.enc',
      mimeHint: mime,
      note: note,
      isFavorite: fav,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );

void main() {
  group('visibleSecureFiles', () {
    test('filters by name, note and type hint (case-insensitive)', () {
      final files = [
        _f('1', name: 'Backup.JSON'),
        _f('2', name: 'photo.png', note: 'passport scan'),
        _f('3', name: 'id_ed25519', mime: 'pem'),
        _f('4', name: 'other.txt'),
      ];
      expect(visibleSecureFiles(files, query: 'backup').single.id, '1');
      expect(visibleSecureFiles(files, query: 'PASSPORT').single.id, '2');
      expect(visibleSecureFiles(files, query: 'pem').single.id, '3');
      expect(visibleSecureFiles(files, query: 'zzz'), isEmpty);
      expect(visibleSecureFiles(files, query: '  ').length, 4);
    });

    test('sorts by recency by default with favourites pinned first', () {
      final files = [
        _f('old', createdAt: 100),
        _f('new', createdAt: 900),
        _f('fav', createdAt: 1, fav: true),
      ];
      final out = visibleSecureFiles(files);
      expect(out.map((f) => f.id).toList(), ['fav', 'new', 'old']);
    });

    test('sorts by name and by size when asked', () {
      final files = [
        _f('b', name: 'beta.txt', size: 5),
        _f('a', name: 'Alpha.txt', size: 50),
        _f('c', name: 'gamma.txt', size: 500),
      ];
      expect(
        visibleSecureFiles(files, sort: SecureFilesSort.name)
            .map((f) => f.id)
            .toList(),
        ['a', 'b', 'c'],
      );
      expect(
        visibleSecureFiles(files, sort: SecureFilesSort.size)
            .map((f) => f.id)
            .toList(),
        ['c', 'a', 'b'],
      );
    });

    test('does not mutate the input list', () {
      final files = [_f('1', createdAt: 5), _f('2', createdAt: 9)];
      visibleSecureFiles(files, sort: SecureFilesSort.name);
      expect(files.first.id, '1');
    });
  });
}
