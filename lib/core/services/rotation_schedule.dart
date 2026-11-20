import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../features/credentials/domain/entities/credential.dart';
import '../infrastructure/vault/data_location.dart';
import '../infrastructure/vault/vault_store.dart';

/// Agenda de rotacion SIN secretos (NUC-2, decision del dueno 2026-11-20): en la v2 el titulo y las fechas de cada
/// credencial van cifrados, asi que el aviso de segundo plano (sin la maestra) lee este archivo: por credencial con
/// rotacion, solo su id, cuando vence y cuando se aviso por ultima vez. El aviso dice cuantas tocan, no cuales.
const String kRotationFileName = 'rotacion.json';

/// Pausa minima entre dos avisos de la misma credencial.
const Duration kRepromptCooldown = Duration(hours: 24);

/// Dias de un intervalo de rotacion; 0 = nunca avisa.
int rotationDaysForInterval(String interval, int? customDays) => switch (interval) {
      'monthly' => 30,
      'quarterly' => 90,
      'semiAnnually' => 180,
      'custom' => customDays ?? 30,
      _ => 0,
    };

/// Una credencial vencida y fuera de la pausa entre avisos.
class DueRotation {
  const DueRotation(this.id, this.daysOverdue);
  final String id;
  final int daysOverdue;
}

class _Entry {
  _Entry(this.dueAt, this.promptedAt);
  final int dueAt;
  int? promptedAt;

  Map<String, dynamic> toJson() => {'dueAt': dueAt, 'promptedAt': promptedAt};
}

Map<String, _Entry> _read(File f) {
  if (!f.existsSync()) return {};
  try {
    final raw = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    return raw.map((id, v) {
      final m = v as Map<String, dynamic>;
      return MapEntry(
        id,
        _Entry((m['dueAt'] as num).toInt(), (m['promptedAt'] as num?)?.toInt()),
      );
    });
  } catch (_) {
    return {};
  }
}

void _write(File f, Map<String, _Entry> m) {
  f.parent.createSync(recursive: true);
  f.writeAsStringSync(jsonEncode(m.map((k, v) => MapEntry(k, v.toJson()))),
      flush: true);
}

/// El archivo de la agenda en el directorio de datos (sirve en el isolate de segundo plano, sin DI).
Future<File> rotationFile() async =>
    File(p.join((await resolveDataLocation()).dataDir, kRotationFileName));

/// Rehace la agenda desde las credenciales. Si el vencimiento cambio (se roto la contrasena), olvida el ultimo aviso.
void rebuildRotationSchedule(File f, List<Credential> credentials) {
  final old = _read(f);
  final next = <String, _Entry>{};
  for (final c in credentials) {
    final days = rotationDaysForInterval(c.rotationInterval, c.customRotationDays);
    if (days <= 0) continue;
    final due = c.updatedAt.add(Duration(days: days)).millisecondsSinceEpoch;
    final prev = old[c.id];
    next[c.id] = _Entry(
      due,
      prev != null && prev.dueAt == due
          ? prev.promptedAt
          : c.lastRotationPromptedAt?.millisecondsSinceEpoch,
    );
  }
  _write(f, next);
}

/// Las vencidas y fuera de la pausa entre avisos.
List<DueRotation> findDueRotations(File f, {DateTime? now}) {
  final at = (now ?? DateTime.now()).millisecondsSinceEpoch;
  final due = <DueRotation>[];
  _read(f).forEach((id, e) {
    if (e.dueAt > at) return;
    final last = e.promptedAt;
    if (last != null && at - last < kRepromptCooldown.inMilliseconds) return;
    due.add(DueRotation(id, (at - e.dueAt) ~/ Duration.millisecondsPerDay));
  });
  return due;
}

/// Marca el aviso (o la pausa, con una fecha futura) de [ids].
void markRotationPrompted(File f, Iterable<String> ids, int atMs) {
  final m = _read(f);
  for (final id in ids) {
    m[id]?.promptedAt = atMs;
  }
  _write(f, m);
}

/// La agenda del directorio de datos de la app, para la parte con DI.
@lazySingleton
class RotationSchedule {
  RotationSchedule(this._vault);

  final VaultStore _vault;

  Future<File> _file() async =>
      File(p.join((await _vault.location()).dataDir, kRotationFileName));

  Future<void> rebuild(List<Credential> credentials) async =>
      rebuildRotationSchedule(await _file(), credentials);

  Future<List<DueRotation>> due({DateTime? now}) async =>
      findDueRotations(await _file(), now: now);

  Future<void> markPrompted(Iterable<String> ids, int atMs) async =>
      markRotationPrompted(await _file(), ids, atMs);

  /// Borra la agenda (al borrar la boveda).
  Future<void> clear() async {
    final f = await _file();
    if (f.existsSync()) f.deleteSync();
  }
}
