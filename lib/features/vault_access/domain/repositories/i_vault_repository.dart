import 'package:solokey/features/vault_access/domain/entities/master_key_config.dart';
import 'package:solokey/features/vault_access/domain/entities/vault.dart';

abstract interface class IVaultRepository {
  Future<Vault?> getVault();
  Future<void> saveVault(Vault vault);
  Future<MasterKeyConfig?> getMasterKeyConfig();
  Future<void> saveMasterKeyConfig(MasterKeyConfig config);
  Future<bool> isVaultInitialized();
}
