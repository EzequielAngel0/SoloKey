import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:solokey/app/di/injection.dart';
import 'package:solokey/core/infrastructure/vault/data_location.dart';
import 'package:solokey/core/infrastructure/vault/vault_store.dart';
import 'package:solokey/features/credentials/domain/repositories/i_credential_repository.dart';
import 'package:solokey/features/secure_files/domain/repositories/i_secure_file_repository.dart';
import 'package:solokey/features/vault_access/application/unlock_vault_use_case.dart';
import 'package:solokey/features/vault_access/application/vault_exceptions.dart';

import 'support/e2e_helpers.dart';

/// Migracion de la v1 a la v2 en el equipo (NUC-2), con la boveda de prueba de los vectores de CAL-2
/// (`vectores/v1/`), nunca con una real: copia la BD drift, `secure_files/` y el almacen seguro a la carpeta AISLADA
/// (NUC-6) y desbloquea por el caso de uso de la app (nucleo Rust, DLL o `.so`, almacen y rutas reales).
///
/// Comprueba: la maestra incorrecta no toca la v1; la correcta (con `ñ` y emoji: la doble codificacion UTF-8 de la
/// v1) migra todo, deja la copia previa, borra los originales y las claves viejas, y la v2 se reabre sin migrar.
///
/// Corre solo con las banderas de borrado aislado y la ruta de los vectores (no hay forma de verlos en Android):
/// `run_integration_tests.ps1` y el job de Windows de la CI le pasan `E2E_ALLOW_WIPE=1`, `SOLOKEY_DATA_DIR` (una
/// carpeta temporal) y `SOLOKEY_V1_VECTORS` (`vectores/v1` del repo).
const String _vectorsDir = String.fromEnvironment('SOLOKEY_V1_VECTORS');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('migra la boveda v1 de los vectores al desbloquear', (tester) async {
    final v = jsonDecode(
            File(p.join(_vectorsDir, 'vectores.json')).readAsStringSync())
        as Map<String, dynamic>;
    final boveda = v['boveda'] as Map<String, dynamic>;
    final titles = {
      for (final c in v['credenciales'] as List) (c as Map)['title'] as String,
    };
    final fileCount = (v['secureFiles'] as List).length;

    await resetVault();
    final loc = await resolveDataLocation();
    File(p.join(_vectorsDir, 'boveda', 'vault_guard_db.sqlite')).copySync(loc.v1Db);
    Directory(loc.v1SecureFiles).createSync(recursive: true);
    for (final f in Directory(p.join(_vectorsDir, 'boveda', 'secure_files'))
        .listSync()
        .whereType<File>()) {
      f.copySync(p.join(loc.v1SecureFiles, p.basename(f.path)));
    }

    await configureDependencies();
    final storage = getIt<FlutterSecureStorage>();
    for (final e in (boveda['secureStorage'] as Map<String, dynamic>).entries) {
      await storage.write(key: e.key, value: e.value as String);
    }
    final unlock = getIt<UnlockVaultUseCase>();
    expect(await getIt<VaultStore>().exists(), isTrue);

    // Maestra incorrecta: falla como siempre y la v1 sigue ahi.
    await expectLater(unlock.execute(boveda['wrongPassword'] as String),
        throwsA(isA<WrongMasterPasswordException>()));
    expect(File(loc.v1Db).existsSync(), isTrue);
    expect(await storage.read(key: 'master_key_config'), isNotNull);

    // Maestra correcta: migra.
    await unlock.execute(boveda['masterPassword'] as String);
    final migrated = await getIt<ICredentialRepository>().getAll();
    expect(migrated.map((c) => c.title).toSet(), titles);
    expect((await getIt<ISecureFileRepository>().getAll()).length, fileCount);

    expect(File(loc.v1Db).existsSync(), isFalse);
    expect(
        Directory(loc.dataDir).listSync().whereType<Directory>().any(
            (d) => p.basename(d.path).startsWith('respaldo-v1-')),
        isTrue);
    expect(await storage.read(key: 'master_key_config'), isNull);
    expect(await storage.read(key: kRecoveryResetNeeded), '1');

    // La v2 se reabre con la misma maestra, sin migrar de nuevo.
    unlock.lock();
    await unlock.execute(boveda['masterPassword'] as String);
    expect((await getIt<ICredentialRepository>().getAll()).length,
        migrated.length);
    unlock.lock();
  }, skip: !e2eCanWipe || _vectorsDir.isEmpty);
}
