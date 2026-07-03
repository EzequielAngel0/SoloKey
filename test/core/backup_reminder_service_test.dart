import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/services/backup_reminder_service.dart';

/// Minimal in-memory [FlutterSecureStorage] for logic tests.
class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data[key];
}

void main() {
  late _FakeSecureStorage storage;
  late BackupReminderService sut;

  setUp(() {
    storage = _FakeSecureStorage();
    sut = BackupReminderService(storage);
  });

  test('is stale when a backup was never exported', () async {
    expect(await sut.lastExportAt(), isNull);
    expect(await sut.isBackupStale(), isTrue);
  });

  test('marking an export clears the stale state', () async {
    await sut.markExportedNow();

    final last = await sut.lastExportAt();
    expect(last, isNotNull);
    expect(await sut.isBackupStale(), isFalse);
  });

  test('becomes stale again after the threshold elapses', () async {
    await sut.markExportedNow();
    final last = await sut.lastExportAt();

    // Just under the threshold → still fresh.
    final almost = last!.add(BackupReminderService.staleAfter);
    expect(await sut.isBackupStale(now: almost), isFalse);

    // Past the threshold → stale.
    final past =
        last.add(BackupReminderService.staleAfter + const Duration(days: 1));
    expect(await sut.isBackupStale(now: past), isTrue);
  });
}
