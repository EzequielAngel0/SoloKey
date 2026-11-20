// Generador de los vectores de prueba de la bóveda v1 (CAL-2).
//
// NO es una prueba ni entra en los gates (ADR-0011): es una herramienta que corre
// el código REAL de la v1 (setup, repositorios, exportación, recuperación, doble
// cifrado) sobre una bóveda de prueba y guarda lo que produce, para que el núcleo
// Rust (NUC-2) demuestre que lee la v1. Se corre en Podman, donde la bóveda real
// del dueño no existe: ver tool/vectores_v1/generar.ps1 y vectores/v1/LEEME.md.
//
// El almacén seguro va en memoria (canal simulado) y la BD en un archivo de una
// carpeta temporal; path_provider apunta a esa carpeta. Al final relee todo con
// el código de la v1 y falla si algo no vuelve igual.
//
// Desde NUC-1 (2026-11-20) la cripto de SecurityServiceImpl la hace el núcleo Rust
// (byte a byte igual: lo prueban estos mismos vectores en `cargo test`) y necesita
// rust/dist/libsolokey_core.so. Los vectores versionados salieron de la cripto Dart
// de la v1 (c0a49a4); para regenerar la verdad de la v1, correrlo desde `main`.

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solokey/core/infrastructure/database/app_database.dart';
import 'package:solokey/core/infrastructure/rust_core.dart';
import 'package:solokey/core/infrastructure/security/double_envelope_service.dart';
import 'package:solokey/core/infrastructure/security/security_service_impl.dart';
import 'package:solokey/core/infrastructure/security/session_manager.dart';
import 'package:solokey/core/services/recovery_service.dart';
import 'package:solokey/core/services/vault_export_service.dart';
import 'package:solokey/features/credentials/domain/entities/credential.dart';
import 'package:solokey/features/credentials/infrastructure/credential_repository_impl.dart';
import 'package:solokey/features/folders/domain/entities/folder.dart';
import 'package:solokey/features/folders/infrastructure/folder_repository_impl.dart';
import 'package:solokey/features/secure_files/infrastructure/secure_file_repository_impl.dart';
import 'package:solokey/features/settings/infrastructure/settings_repository_impl.dart';
import 'package:solokey/features/vault_access/application/setup_vault_use_case.dart';
import 'package:solokey/features/vault_access/infrastructure/vault_repository_impl.dart';

// ── Datos fijos de la bóveda de prueba (no son secretos de nadie) ─────────────
const masterPassword = 'Prueba-v1 contraseña maestra ñ 🔑';
const wrongPassword = 'Prueba-v1 contraseña maestra ñ 🔐';
const exportPassword = 'exportación de prueba v1';
const doublePin = '482915';

final t0 = DateTime.utc(2026, 1, 2, 3, 4, 5);
DateTime at(int minutes) => t0.add(Duration(minutes: minutes));

/// Lo que la v1 pasa al Argon2id como contraseña MAESTRA (setup_vault_use_case.dart y
/// unlock_vault_use_case.dart): `String.fromCharCodes(utf8.encode(pw))`, que el paquete
/// `cryptography` vuelve a codificar en UTF-8. Es decir, los bytes UTF-8 de la contraseña
/// leídos como Latin-1 y codificados otra vez: doble codificación. Con ASCII no cambia nada;
/// con `ñ`, acentos o emoji sí. El PIN del doble cifrado y la contraseña de exportación NO
/// pasan por esto (van directo).
String v1MasterKdfInput(String pw) => String.fromCharCodes(utf8.encode(pw));

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

Map<String, String> installMemorySecureStorage() {
  final store = <String, String>{};
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
    final a = (call.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    switch (call.method) {
      case 'write':
        final v = a['value'] as String?;
        v == null ? store.remove(a['key']) : store[a['key'] as String] = v;
        return null;
      case 'read':
        return store[a['key']];
      case 'delete':
        store.remove(a['key']);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'containsKey':
        return store.containsKey(a['key']);
    }
    return null;
  });
  return store;
}

void installPathProvider(String dir) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => dir);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('genera los vectores de la boveda v1', () async {
    final out = Directory(
        Platform.environment['VECTORES_SALIDA'] ?? 'vectores/v1');
    final boveda = Directory('${out.path}/boveda');
    if (await boveda.exists()) await boveda.delete(recursive: true);
    await boveda.create(recursive: true);
    installPathProvider(boveda.path);
    final store = installMemorySecureStorage();

    const storage = FlutterSecureStorage();
    await initRustCore();
    final security = SecurityServiceImpl();
    final session = SessionManager();
    final dbFile = File('${boveda.path}/vault_guard_db.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    const vaultRepo = VaultRepositoryImpl(storage);
    const settingsRepo = SettingsRepositoryImpl(storage);
    final credRepo = CredentialRepositoryImpl(
        db.credentialDao, db.passwordHistoryDao, security, session);
    final folderRepo = FolderRepositoryImpl(db.folderDao);
    final fileRepo = SecureFileRepositoryImpl(db.secureFileDao, security, session);
    final envelope = DoubleEnvelopeService(security, storage);

    // ── 1. Setup: KDF, sal y verificationData los produce la v1 ──────────────
    await SetupVaultUseCase(vaultRepo, settingsRepo, security, session)
        .execute(masterPassword);
    final masterKey = session.getKeyCopy()!;
    final config =
        jsonDecode(store['master_key_config']!) as Map<String, dynamic>;
    final recoveryCode =
        await RecoveryService(storage, security, session, vaultRepo)
            .generateRecoveryCode();

    // ── 2. Carpetas (anidadas) y credenciales de cada tipo ───────────────────
    final folders = [
      Folder(id: 'f0000000-0000-4000-8000-000000000001', name: 'Trabajo', createdAt: at(1)),
      Folder(
          id: 'f0000000-0000-4000-8000-000000000002',
          parentId: 'f0000000-0000-4000-8000-000000000001',
          name: 'Servidores ñandú',
          icon: 'dns',
          colorHex: '#00897B',
          isFavorite: true,
          createdAt: at(2)),
    ];
    for (final f in folders) {
      await folderRepo.save(f);
    }
    await db.categoryDao.upsert(CategoryEntriesCompanion.insert(
        id: 'c0000000-0000-4000-8000-000000000001',
        name: 'Categoría heredada',
        icon: 'label',
        createdAt: at(3).millisecondsSinceEpoch));

    final longNote = List.filled(40, 'Línea larga con acentos áéíóú y 🔒.').join('\n');
    final creds = <Credential>[
      Credential(
          id: 'a0000000-0000-4000-8000-000000000001',
          type: CredentialType.password,
          title: 'Correo personal',
          username: 'persona@example.com',
          password: r'P@ss w0rd "comillas" \barra ñ 😀',
          website: 'https://mail.example.com/login?x=1&y=2',
          notes: 'Nota corta',
          customFields: const [
            CustomField(label: 'PIN', value: '0420', isSecret: true),
            CustomField(label: 'Pregunta', value: 'Color favorito: azul'),
          ],
          isFavorite: true,
          sortOrder: 2,
          rotationInterval: 'custom',
          customRotationDays: 45,
          lastRotationPromptedAt: at(30),
          createdAt: at(10),
          updatedAt: at(11)),
      Credential(
          id: 'a0000000-0000-4000-8000-000000000002',
          type: CredentialType.apiKey,
          title: 'API de pruebas',
          password: 'sk_test_0123456789abcdefABCDEF',
          categoryId: 'f0000000-0000-4000-8000-000000000002',
          rotationInterval: 'quarterly',
          createdAt: at(12),
          updatedAt: at(12)),
      Credential(
          id: 'a0000000-0000-4000-8000-000000000003',
          type: CredentialType.secureNote,
          title: 'Nota segura larga',
          notes: longNote,
          isHidden: true,
          createdAt: at(13),
          updatedAt: at(14)),
      Credential(
          id: 'a0000000-0000-4000-8000-000000000004',
          type: CredentialType.totp,
          title: 'TOTP de ejemplo',
          username: 'persona',
          password:
              'otpauth://totp/Ejemplo:persona?secret=JBSWY3DPEHPK3PXP&issuer=Ejemplo&algorithm=SHA1&digits=6&period=30',
          categoryId: 'f0000000-0000-4000-8000-000000000001',
          createdAt: at(15),
          updatedAt: at(15)),
      Credential(
          id: 'a0000000-0000-4000-8000-000000000005',
          type: CredentialType.passkey,
          title: 'Passkey de ejemplo',
          username: 'persona',
          password: base64Encode(List<int>.generate(32, (i) => i)),
          website: 'https://example.com',
          passkeyMetadata: const PasskeyMetadata(
              rpId: 'example.com',
              rpName: 'Example Inc.',
              credentialId: 'Y3JlZGVudGlhbC1pZC1kZS1wcnVlYmE',
              aaguid: '00000000-0000-0000-0000-000000000000',
              userDisplayName: 'Persona de Prueba'),
          createdAt: at(16),
          updatedAt: at(16)),
      Credential(
          id: 'a0000000-0000-4000-8000-000000000006',
          type: CredentialType.sshKey,
          title: 'Llave SSH',
          sshKeyMetadata: const SshKeyMetadata(
              privateKey:
                  '-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAA\n-----END OPENSSH PRIVATE KEY-----\n',
              publicKey: 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIprueba persona@equipo',
              passphrase: 'frase de paso'),
          createdAt: at(17),
          updatedAt: at(17)),
      Credential(
          id: 'a0000000-0000-4000-8000-000000000007',
          type: CredentialType.password,
          title: 'Vacía (solo título)',
          createdAt: at(18),
          updatedAt: at(18)),
    ];

    // Doble cifrado con PIN, como lo hace credential_form_screen.dart.
    final plainDouble = Credential(
        id: 'a0000000-0000-4000-8000-000000000008',
        type: CredentialType.password,
        title: 'Banco (doble cifrado)',
        username: 'cliente-123',
        password: 'clave del banco ñ',
        customFields: const [
          CustomField(label: 'NIP', value: '9876', isSecret: true),
          CustomField(label: 'Sucursal', value: 'Centro'),
        ],
        isDoubleEncrypted: true,
        createdAt: at(19),
        updatedAt: at(19));
    final doubleCred = plainDouble.copyWith(
      password: await envelope.encryptField(
          plaintext: plainDouble.password!, pin: doublePin),
      customFields: [
        plainDouble.customFields[0].copyWith(
            value: await envelope.encryptField(
                plaintext: plainDouble.customFields[0].value, pin: doublePin)),
        plainDouble.customFields[1],
      ],
    );
    creds.add(doubleCred);

    for (final c in creds) {
      await credRepo.save(c);
    }
    // Segunda versión de la primera: deja historial (password_history_entries).
    await credRepo.save(creds[0].copyWith(
        password: 'contraseña nueva v2', updatedAt: at(20)));
    // En la v1 mover a carpeta escribe en category_id (folder_id está en desuso).
    await credRepo.moveToFolder(
        'a0000000-0000-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000001');

    // ── 3. Archivos seguros ──────────────────────────────────────────────────
    final fileInputs = <String, Uint8List>{
      'factura ñ.pdf': Uint8List.fromList(utf8.encode('%PDF-1.4 contenido de prueba ñ')),
      'vacío.txt': Uint8List(0),
      'binario.bin': Uint8List.fromList(List<int>.generate(4096, (i) => (i * 7) % 256)),
    };
    final files = [];
    for (final e in fileInputs.entries) {
      final sf = await fileRepo.addFile(name: e.key, bytes: e.value, note: 'nota de ${e.key}');
      files.add({
        'id': sf.id,
        'name': sf.name,
        'storedFileName': sf.storedFileName,
        'plaintextBase64': base64Encode(e.value),
        'plaintextSha256': hex(await security.sha256(e.value)),
      });
    }

    // ── 4. Exportación .skvault (v2 del formato de exportación de la v1) ─────
    final export = VaultExportService(credRepo, folderRepo, security, session);
    final exportPath = await export.exportVaultToDirectory(
        exportPassword: exportPassword, directoryPath: boveda.path);
    final skvault = File('${boveda.path}/export.skvault');
    await File(exportPath).rename(skvault.path);

    // ── 5. Vectores sueltos de cripto (KDF, AES-GCM, doble cifrado) ──────────
    final aesKey = Uint8List.fromList(List<int>.generate(32, (i) => 255 - i));
    final aesPlain = Uint8List.fromList(utf8.encode('vector AES-GCM de la v1 ñ'));
    final aesBlob = await security.encrypt(aesPlain, aesKey);
    final doubleSample = await envelope.encryptField(plaintext: 'campo doble', pin: doublePin);
    final doubleSalt = doubleSample.split(':')[1];
    final doubleKey = await security.deriveKey(
        password: doublePin, saltBase64: doubleSalt, memory: 32768, iterations: 2, parallelism: 2);

    // ── 6. Filas tal como quedan en la BD ────────────────────────────────────
    Future<List<Map<String, Object?>>> rows(String table, String order) async {
      final r = await db.customSelect('SELECT * FROM $table ORDER BY $order').get();
      return r.map((row) => row.data.map((k, v) =>
          MapEntry(k, v is Uint8List ? {'hex': hex(v)} : v))).toList();
    }

    final credRows = await db
        .customSelect('SELECT id, encrypted_payload FROM credential_entries ORDER BY id')
        .get();
    final payloads = <Map<String, Object?>>[];
    for (final r in credRows) {
      final blob = r.read<Uint8List>('encrypted_payload');
      payloads.add({
        'id': r.read<String>('id'),
        'payloadJson': utf8.decode(await security.decrypt(blob, masterKey)),
      });
    }
    final schemaVersion = (await db.customSelect('PRAGMA user_version').getSingle())
        .data.values.first;

    final vectors = {
      'formato': 'vectores-solokey-v1',
      'generadoCon': 'tool/vectores_v1/generar_vectores.dart (codigo de la app v1)',
      'generadoEl': DateTime.now().toUtc().toIso8601String(),
      'nota': 'Boveda de PRUEBA; ningun dato es real. Fechas en ms desde epoch (UTC).',
      'boveda': {
        'masterPassword': masterPassword,
        'wrongPassword': wrongPassword,
        'masterKeyConfig': config,
        'derivedKeyHex': hex(masterKey),
        'verificationPlaintext': 'SoloKey::v1::verify',
        'recoveryCode': recoveryCode,
        'secureStorage': Map<String, String>.from(store),
        'schemaVersion': schemaVersion,
        'archivos': {
          'bd': 'boveda/vault_guard_db.sqlite',
          'secureFiles': 'boveda/secure_files/',
          'export': 'boveda/export.skvault',
        },
      },
      'kdf': [
        {
          'uso': 'boveda (Argon2id 64 MiB, 3, 4, 32 B); entrada con doble codificacion UTF-8',
          'password': masterPassword,
          'kdfInputHex': hex(utf8.encode(v1MasterKdfInput(masterPassword))),
          'saltBase64': config['salt'],
          'memoryKiB': 65536, 'iterations': 3, 'parallelism': 4,
          'keyHex': hex(masterKey),
        },
        {
          'uso': 'doble cifrado con PIN (Argon2id 32 MiB, 2, 2, 32 B)',
          'password': doublePin,
          'kdfInputHex': hex(utf8.encode(doublePin)),
          'saltBase64': doubleSalt,
          'memoryKiB': 32768, 'iterations': 2, 'parallelism': 2,
          'keyHex': hex(doubleKey),
        },
      ],
      'aesGcm': {
        'formato': 'nonce(12) || ciphertext || tag(16)',
        'keyHex': hex(aesKey),
        'plaintextUtf8': utf8.decode(aesPlain),
        'blobHex': hex(aesBlob),
      },
      'dobleCifrado': {
        'formato': 'double_enc_v1:<sal base64>:<base64(nonce||ct||tag)>',
        'pin': doublePin,
        'muestra': doubleSample,
        'plaintext': 'campo doble',
        'credencial': doubleCred.id,
        'plaintextDeLaCredencial': {
          'password': plainDouble.password,
          'customFields[0]': plainDouble.customFields[0].value,
        },
      },
      'export': {
        'archivo': 'boveda/export.skvault',
        'formato': 'magic "SKVE2\\0\\0\\0"(8) || sal(32) || nonce(12) || ct || tag(16); Argon2id 64 MiB, 3, 2',
        'password': exportPassword,
        'kdfInputHex': hex(utf8.encode(exportPassword)),
        'nota': 'La contrasena de exportacion va directa en UTF-8 (sin la doble codificacion de la maestra)',
      },
      'credenciales': [
        for (final c in creds)
          {'id': c.id, 'type': c.type.name, 'title': c.title},
      ],
      'payloads': payloads,
      'secureFiles': files,
      'filas': {
        'credential_entries': await rows('credential_entries', 'id'),
        'folder_entries': await rows('folder_entries', 'id'),
        'category_entries': await rows('category_entries', 'id'),
        'password_history_entries':
            await rows('password_history_entries', 'credential_id, created_at, id'),
        'secure_file_entries': await rows('secure_file_entries', 'name'),
      },
    };

    // ── 7. Releer con la v1 (desbloqueo desde cero) y comprobar ──────────────
    session.lock();
    final cfg = (await vaultRepo.getMasterKeyConfig())!;
    final again = await security.deriveKey(
        password: v1MasterKdfInput(masterPassword),
        saltBase64: cfg.salt,
        memory: cfg.kdfParams.memory,
        iterations: cfg.kdfParams.iterations,
        parallelism: cfg.kdfParams.parallelism);
    expect(await security.verifyKey(again, cfg.verificationData), isTrue);
    expect(hex(again), hex(masterKey), reason: 'la clave del setup se re-deriva igual');
    final wrong = await security.deriveKey(
        password: v1MasterKdfInput(wrongPassword),
        saltBase64: cfg.salt,
        memory: cfg.kdfParams.memory,
        iterations: cfg.kdfParams.iterations,
        parallelism: cfg.kdfParams.parallelism);
    expect(await security.verifyKey(wrong, cfg.verificationData), isFalse);
    session.storeKey(again);
    final readBack = await credRepo.getAll();
    expect(readBack.length, creds.length);
    expect(readBack.firstWhere((c) => c.id == creds[0].id).password,
        'contraseña nueva v2');
    for (final f in files) {
      final bytes = await fileRepo.readDecrypted(f['id'] as String);
      expect(base64Encode(bytes), f['plaintextBase64']);
    }
    expect(Directory('${boveda.path}/secure_files').listSync().length, files.length);
    final dec = await export.decryptBackup(
        fileBytes: await skvault.readAsBytes(), exportPassword: exportPassword);
    expect(dec.credentials.length, creds.length);
    expect(dec.folders.length, folders.length);
    expect(
        await envelope.decryptField(encryptedValue: doubleCred.password!, pin: doublePin),
        plainDouble.password);
    expect(
        await security.decrypt(aesBlob, aesKey),
        aesPlain);

    await db.close();
    // Sin -wal/-shm sueltos: el archivo de la BD queda completo.
    for (final ext in ['-wal', '-shm', '-journal']) {
      final f = File('${dbFile.path}$ext');
      if (await f.exists()) await f.delete();
    }
    await File('${out.path}/vectores.json').writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(vectors)}\n');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
