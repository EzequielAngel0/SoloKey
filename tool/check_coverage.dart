import 'dart:io';

/// Coverage gate: parses `coverage/lcov.info` and fails (exit 1) if total line
/// coverage is below the minimum passed as the first arg (default 0).
///
/// Generated files (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gr.dart`)
/// are excluded from the denominator so the number reflects hand-written code.
///
/// Usage: `flutter test --coverage && dart run tool/check_coverage.dart 25`
void main(List<String> args) {
  final min = args.isNotEmpty ? (double.tryParse(args.first) ?? 0) : 0;
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('No existe coverage/lcov.info. Corre: flutter test --coverage');
    exit(2);
  }

  bool isGenerated(String path) {
    final p = path.replaceAll('\\', '/');
    return p.endsWith('.g.dart') ||
        p.endsWith('.freezed.dart') ||
        p.endsWith('.config.dart') ||
        p.endsWith('.gr.dart') ||
        // gen-l10n output (AppLocalizations delegates) is generated code.
        p.contains('lib/l10n/app_localizations');
  }

  var found = 0;
  var hit = 0;
  var skip = false;
  final worst = <String, ({int lf, int lh})>{};
  String? current;
  var curLf = 0;
  var curLh = 0;

  void flush() {
    if (current != null && !skip && curLf > 0) {
      worst[current] = (lf: curLf, lh: curLh);
    }
    curLf = 0;
    curLh = 0;
  }

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      flush();
      current = line.substring(3);
      skip = isGenerated(current);
    } else if (line.startsWith('LF:')) {
      final n = int.parse(line.substring(3));
      curLf = n;
      if (!skip) found += n;
    } else if (line.startsWith('LH:')) {
      final n = int.parse(line.substring(3));
      curLh = n;
      if (!skip) hit += n;
    }
  }
  flush();

  final pct = found == 0 ? 0.0 : hit / found * 100;
  stdout.writeln(
      'Cobertura (sin generados): ${pct.toStringAsFixed(2)}%  ($hit/$found lineas)');

  // Show the 12 biggest uncovered gaps to guide the next tests.
  final gaps = worst.entries.toList()
    ..sort((a, b) => (b.value.lf - b.value.lh).compareTo(a.value.lf - a.value.lh));
  stdout.writeln('\nMayores huecos (lineas sin cubrir):');
  for (final e in gaps.take(12)) {
    final miss = e.value.lf - e.value.lh;
    if (miss <= 0) continue;
    final rel = e.key.replaceAll('\\', '/').replaceFirst(RegExp(r'^.*/lib/'), 'lib/');
    stdout.writeln('  ${miss.toString().padLeft(4)}  $rel');
  }

  if (pct + 1e-9 < min) {
    stderr.writeln('\nFALLO: cobertura ${pct.toStringAsFixed(2)}% < minimo $min%');
    exit(1);
  }
}
