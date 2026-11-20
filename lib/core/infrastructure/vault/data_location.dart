import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Directorio de datos aislado para las pruebas (NUC-6): `--dart-define=SOLOKEY_DATA_DIR=<ruta>`. Una ruta relativa
/// cuelga del directorio de soporte de la app (sirve igual en Android y en Windows).
/// Un build release lo ignora siempre: la boveda real solo vive en la ruta del sistema.
const String _dataDirOverride = String.fromEnvironment('SOLOKEY_DATA_DIR');

/// True cuando la app corre con datos aislados (bandera de prueba y build que no es release).
bool get isIsolatedDataDir => !kReleaseMode && _dataDirOverride.isNotEmpty;

/// Donde vive cada cosa en disco.
class DataLocation {
  const DataLocation({
    required this.dataDir,
    required this.v1Db,
    required this.v1SecureFiles,
  });

  /// Boveda v2, agenda de rotacion y copias de la v1.
  final String dataDir;

  /// BD drift de la v1 (`vault_guard_db.sqlite`), solo para migrarla.
  final String v1Db;

  /// Carpeta `secure_files/` de la v1, solo para migrarla.
  final String v1SecureFiles;

  /// Carpeta nueva para la copia previa a la migracion.
  String backupDir(DateTime at) {
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp = '${at.year}${two(at.month)}${two(at.day)}-'
        '${two(at.hour)}${two(at.minute)}${two(at.second)}';
    return p.join(dataDir, 'respaldo-v1-$stamp');
  }
}

/// Resuelve las rutas. Con [isIsolatedDataDir] todo (tambien la v1 a migrar) cuelga de la carpeta de la bandera;
/// si no, la v2 va al soporte de la app y la v1 esta donde la dejaba drift (Documentos) y su `secure_files/`.
Future<DataLocation> resolveDataLocation() async {
  final support = await getApplicationSupportDirectory();
  if (isIsolatedDataDir) {
    final dir = Directory(p.isAbsolute(_dataDirOverride)
        ? _dataDirOverride
        : p.join(support.path, _dataDirOverride));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return DataLocation(
      dataDir: dir.path,
      v1Db: p.join(dir.path, 'vault_guard_db.sqlite'),
      v1SecureFiles: p.join(dir.path, 'secure_files'),
    );
  }
  final docs = await getApplicationDocumentsDirectory();
  if (!support.existsSync()) support.createSync(recursive: true);
  return DataLocation(
    dataDir: support.path,
    v1Db: p.join(docs.path, 'vault_guard_db.sqlite'),
    v1SecureFiles: p.join(support.path, 'secure_files'),
  );
}
