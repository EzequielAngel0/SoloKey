import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;

import 'data_location.dart';

/// Almacen "seguro" de PRUEBA (NUC-6): un JSON en la carpeta aislada, para que las E2E no toquen el almacen real
/// del sistema. Sin cifrar: solo se usa con [isIsolatedDataDir], que un build release ignora.
class FileSecureStorage extends FlutterSecureStorage {
  FileSecureStorage();

  static const fileName = 'almacen_prueba.json';

  Future<File> _file() async =>
      File(p.join((await resolveDataLocation()).dataDir, fileName));

  Future<Map<String, String>> _load() async {
    final f = await _file();
    if (!f.existsSync()) return {};
    final raw = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    return raw.map((k, v) => MapEntry(k, v as String));
  }

  Future<void> _save(Map<String, String> m) async {
    final f = await _file();
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(jsonEncode(m), flush: true);
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final m = await _load();
    if (value == null) {
      m.remove(key);
    } else {
      m[key] = value;
    }
    await _save(m);
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      (await _load())[key];

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      (await _load()).containsKey(key);

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final m = (await _load())..remove(key);
    await _save(m);
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) =>
      _load();

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final f = await _file();
    if (f.existsSync()) f.deleteSync();
  }
}
