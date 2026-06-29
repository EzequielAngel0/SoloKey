import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';

import '../../features/credentials/domain/entities/credential.dart';
import '../../features/credentials/domain/repositories/i_credential_repository.dart';

enum AuditSeverity { critical, warning, info }

/// Categorised audit finding. Carries a [type] + numeric params instead of
/// display text, so the presentation layer (which has a BuildContext) localizes
/// it. Keeps the service free of UI strings.
enum AuditIssueType {
  tooShort,
  weakLettersOnly,
  weakNumbersOnly,
  reused,
  breached,
  noPassword,
  rotationDue,
  stale,
}

class AuditIssue {
  const AuditIssue({
    required this.credential,
    required this.severity,
    required this.type,
    this.breachCount = 0,
    this.daysOverdue = 0,
    this.intervalDays = 0,
    this.daysSinceUpdate = 0,
  });
  final Credential credential;
  final AuditSeverity severity;
  final AuditIssueType type;

  /// Number of breaches ([AuditIssueType.breached]).
  final int breachCount;

  /// Days past the rotation window ([AuditIssueType.rotationDue]).
  final int daysOverdue;

  /// Configured rotation interval in days ([AuditIssueType.rotationDue]).
  final int intervalDays;

  /// Days since last update ([AuditIssueType.stale]).
  final int daysSinceUpdate;
}

@lazySingleton
class SecurityAuditService {
  SecurityAuditService(this._credRepo);

  final ICredentialRepository _credRepo;

  Future<List<AuditIssue>> runAudit({bool checkBreaches = false}) async {
    final credentials = await _credRepo.getAll();
    final issues = <AuditIssue>[];

    // Build frequency map for password reuse detection
    final passwordCount = <String, int>{};
    for (final c in credentials) {
      if (c.password != null && c.password!.isNotEmpty) {
        passwordCount[c.password!] = (passwordCount[c.password!] ?? 0) + 1;
      }
    }

    final breachChecks = <Future<void>>[];

    for (final c in credentials) {
      if (c.type == CredentialType.secureNote ||
          c.type == CredentialType.totp ||
          c.type == CredentialType.passkey ||
          c.type == CredentialType.sshKey) {
        continue;
      }

      final pwd = c.password;

      // Weak password check
      if (pwd != null && pwd.isNotEmpty) {
        if (pwd.length < 8) {
          issues.add(AuditIssue(
            credential: c,
            severity: AuditSeverity.critical,
            type: AuditIssueType.tooShort,
          ));
        } else if (_isOnlyLetters(pwd)) {
          issues.add(AuditIssue(
            credential: c,
            severity: AuditSeverity.warning,
            type: AuditIssueType.weakLettersOnly,
          ));
        } else if (_isOnlyNumbers(pwd)) {
          issues.add(AuditIssue(
            credential: c,
            severity: AuditSeverity.warning,
            type: AuditIssueType.weakNumbersOnly,
          ));
        }

        // Reuse check
        if ((passwordCount[pwd] ?? 0) > 1) {
          issues.add(AuditIssue(
            credential: c,
            severity: AuditSeverity.warning,
            type: AuditIssueType.reused,
          ));
        }

        // HaveIBeenPwned check
        if (checkBreaches) {
          breachChecks.add(() async {
            final count = await checkBreachCount(pwd);
            if (count > 0) {
              issues.add(AuditIssue(
                credential: c,
                severity: AuditSeverity.critical,
                type: AuditIssueType.breached,
                breachCount: count,
              ));
            }
          }());
        }
      } else if (c.type == CredentialType.password) {
        // Without password
        issues.add(AuditIssue(
          credential: c,
          severity: AuditSeverity.critical,
          type: AuditIssueType.noPassword,
        ));
      }

      // Staleness check / Rotation Reminder check
      if (c.rotationInterval != 'none') {
        final days = switch (c.rotationInterval) {
          'monthly' => 30,
          'quarterly' => 90,
          'semiAnnually' => 180,
          'custom' => c.customRotationDays ?? 30,
          _ => 0,
        };

        if (days > 0) {
          final daysSinceUpdate = DateTime.now().difference(c.updatedAt).inDays;
          if (daysSinceUpdate >= days) {
            issues.add(AuditIssue(
              credential: c,
              severity: AuditSeverity.warning,
              type: AuditIssueType.rotationDue,
              daysOverdue: daysSinceUpdate - days,
              intervalDays: days,
            ));
          }
        }
      } else {
        final daysSinceUpdate = DateTime.now().difference(c.updatedAt).inDays;
        if (daysSinceUpdate >= 180) {
          issues.add(AuditIssue(
            credential: c,
            severity: AuditSeverity.info,
            type: AuditIssueType.stale,
            daysSinceUpdate: daysSinceUpdate,
          ));
        }
      }
    }

    if (breachChecks.isNotEmpty) {
      await Future.wait(breachChecks);
    }

    // Sort: critical → warning → info
    issues.sort((a, b) => a.severity.index.compareTo(b.severity.index));
    return issues;
  }

  Future<int> checkBreachCount(String password) async {
    try {
      final bytes = utf8.encode(password);
      final digest = sha1.convert(bytes).toString().toUpperCase();
      final prefix = digest.substring(0, 5);
      final suffix = digest.substring(5);

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse('https://api.pwnedpasswords.com/range/$prefix'));
      final response = await request.close();
      if (response.statusCode != 200) {
        return 0;
      }
      final responseBody = await response.transform(utf8.decoder).join();
      final lines = LineSplitter.split(responseBody);
      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length == 2 && parts[0] == suffix) {
          return int.tryParse(parts[1]) ?? 0;
        }
      }
    } catch (_) {
      // Return 0 if network is offline or fails
    }
    return 0;
  }

  bool _isOnlyLetters(String s) => RegExp(r'^[a-zA-Z]+$').hasMatch(s);
  bool _isOnlyNumbers(String s) => RegExp(r'^\d+$').hasMatch(s);
}
