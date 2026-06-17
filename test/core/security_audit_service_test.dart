import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/services/security_audit_service.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/domain/entities/password_history.dart';
import 'package:password_manager/features/credentials/domain/repositories/i_credential_repository.dart';

class FakeCredentialRepository implements ICredentialRepository {
  FakeCredentialRepository(this.credentials);
  final List<Credential> credentials;

  @override
  Future<List<Credential>> getAll() async => credentials;

  @override
  Future<Credential?> getById(String id) async => credentials.firstWhere((c) => c.id == id);

  @override
  Future<void> save(Credential credential) async {}

  @override
  Future<void> update(Credential credential) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<Credential>> getByCategory(String categoryId) async => [];

  @override
  Future<List<Credential>> getFavorites() async => [];

  @override
  Future<List<Credential>> search(String query) async => [];

  @override
  Future<List<PasswordHistory>> getPasswordHistory(String credentialId) async => [];
}

class TestSecurityAuditService extends SecurityAuditService {
  TestSecurityAuditService(super.credRepo);

  @override
  Future<int> checkBreachCount(String password) async {
    if (password == 'breached123') {
      return 15;
    }
    return 0;
  }
}

void main() {
  group('SecurityAuditService Tests', () {
    test('Identifies weak and short passwords', () async {
      final now = DateTime.now();
      final credentials = [
        Credential(
          id: '1',
          type: CredentialType.password,
          title: 'Short password',
          password: '123',
          createdAt: now,
          updatedAt: now,
        ),
        Credential(
          id: '2',
          type: CredentialType.password,
          title: 'Only letters',
          password: 'abcdefgh',
          createdAt: now,
          updatedAt: now,
        ),
        Credential(
          id: '3',
          type: CredentialType.password,
          title: 'Only numbers',
          password: '123456789',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final repo = FakeCredentialRepository(credentials);
      final service = SecurityAuditService(repo);
      final issues = await service.runAudit();

      final shortIssues = issues.where((i) => i.title == 'Contraseña demasiado corta');
      expect(shortIssues.length, 1);
      expect(shortIssues.first.credential.id, '1');

      final weakIssues = issues.where((i) => i.title == 'Contraseña débil');
      expect(weakIssues.length, 2);
    });

    test('Identifies reused passwords', () async {
      final now = DateTime.now();
      final credentials = [
        Credential(
          id: '1',
          type: CredentialType.password,
          title: 'Reused 1',
          password: 'SamePassword123!',
          createdAt: now,
          updatedAt: now,
        ),
        Credential(
          id: '2',
          type: CredentialType.password,
          title: 'Reused 2',
          password: 'SamePassword123!',
          createdAt: now,
          updatedAt: now,
        ),
        Credential(
          id: '3',
          type: CredentialType.password,
          title: 'Unique',
          password: 'UniquePassword123!',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final repo = FakeCredentialRepository(credentials);
      final service = SecurityAuditService(repo);
      final issues = await service.runAudit();

      final reusedIssues = issues.where((i) => i.title == 'Contraseña reutilizada');
      expect(reusedIssues.length, 2);
      expect(reusedIssues.any((i) => i.credential.id == '1'), isTrue);
      expect(reusedIssues.any((i) => i.credential.id == '2'), isTrue);
      expect(reusedIssues.any((i) => i.credential.id == '3'), isFalse);
    });

    test('Identifies old passwords', () async {
      final oldDate = DateTime.now().subtract(const Duration(days: 95));
      final credentials = [
        Credential(
          id: '1',
          type: CredentialType.password,
          title: 'Old',
          password: 'StrongPassword123!',
          createdAt: oldDate,
          updatedAt: oldDate,
        ),
      ];

      final repo = FakeCredentialRepository(credentials);
      final service = SecurityAuditService(repo);
      final issues = await service.runAudit();

      final oldIssues = issues.where((i) => i.title == 'Contraseña antigua');
      expect(oldIssues.length, 1);
      expect(oldIssues.first.credential.id, '1');
    });

    test('Identifies missing passwords for password credentials', () async {
      final now = DateTime.now();
      final credentials = [
        Credential(
          id: '1',
          type: CredentialType.password,
          title: 'No password',
          password: '',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final repo = FakeCredentialRepository(credentials);
      final service = SecurityAuditService(repo);
      final issues = await service.runAudit();

      final missingIssues = issues.where((i) => i.title == 'Sin contraseña guardada');
      expect(missingIssues.length, 1);
    });

    test('Ignores notes and TOTPs for weak password checks', () async {
      final now = DateTime.now();
      final credentials = [
        Credential(
          id: '1',
          type: CredentialType.secureNote,
          title: 'Secure Note',
          password: '123', // should be ignored
          createdAt: now,
          updatedAt: now,
        ),
        Credential(
          id: '2',
          type: CredentialType.totp,
          title: 'TOTP',
          password: '123', // should be ignored
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final repo = FakeCredentialRepository(credentials);
      final service = SecurityAuditService(repo);
      final issues = await service.runAudit();

      final shortIssues = issues.where((i) => i.title == 'Contraseña demasiado corta');
      expect(shortIssues.length, 0);
    });

    test('Identifies breached passwords when checkBreaches is true', () async {
      final now = DateTime.now();
      final credentials = [
        Credential(
          id: '1',
          type: CredentialType.password,
          title: 'Breached',
          password: 'breached123',
          createdAt: now,
          updatedAt: now,
        ),
        Credential(
          id: '2',
          type: CredentialType.password,
          title: 'Safe',
          password: 'safePassword123!',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final repo = FakeCredentialRepository(credentials);
      final service = TestSecurityAuditService(repo);

      // checkBreaches = false
      final issuesNormal = await service.runAudit(checkBreaches: false);
      expect(issuesNormal.any((i) => i.title == 'Contraseña filtrada'), isFalse);

      // checkBreaches = true
      final issuesWithBreach = await service.runAudit(checkBreaches: true);
      final breachedIssues = issuesWithBreach.where((i) => i.title == 'Contraseña filtrada');
      expect(breachedIssues.length, 1);
      expect(breachedIssues.first.credential.id, '1');
      expect(breachedIssues.first.description.contains('15'), isTrue);
    });
  });
}
