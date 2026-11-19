import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/injection.dart';
import '../domain/entities/password_history.dart';
import '../domain/repositories/i_credential_repository.dart';

part 'password_history_provider.g.dart';

@riverpod
Future<List<PasswordHistory>> passwordHistory(Ref ref, String credentialId) async {
  final repo = getIt<ICredentialRepository>();
  return repo.getPasswordHistory(credentialId);
}
