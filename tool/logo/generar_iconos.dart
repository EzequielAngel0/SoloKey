// Genera los iconos de SoloKey desde el logo plano del kit (DIS-4).
//
//   flutter test tool/logo/generar_iconos.dart
//   dart run flutter_launcher_icons        (mipmaps de Android desde los PNG)
//
// No es una prueba: usa el motor de pintado de `flutter test` para dibujar
// `SoloKeyAppIcon` y `SoloKeyMark` y escribir los archivos. Escribe:
//   assets/logo/solokey_icon.png         icono 1024 (Android antiguo)
//   assets/logo/SoloKey.png              el mismo (bandeja fuera de Windows)
//   assets/logo/solokey_adaptive_fg.png  frente del adaptativo de Android
//   assets/logo/SoloKey.ico              bandeja y ventana de Windows
//   windows/runner/resources/app_icon.ico  .exe e instalador
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solokey/shared/widgets/kit/kit.dart';

const _icoSizes = [16, 24, 32, 48, 64, 128, 256];

Future<Uint8List> _render(WidgetTester tester, int px, Widget child) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: RepaintBoundary(
          key: key,
          child: SizedBox.square(dimension: px.toDouble(), child: child),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
  late Uint8List bytes;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await boundary.toImage(pixelRatio: 1);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    bytes = data!.buffer.asUint8List();
  });
  return bytes;
}

/// `.ico` con un PNG por tamaño (Windows Vista en adelante lo lee).
Uint8List _ico(Map<int, Uint8List> frames) {
  final b = BytesBuilder();
  final head = ByteData(6)
    ..setUint16(0, 0, Endian.little)
    ..setUint16(2, 1, Endian.little)
    ..setUint16(4, frames.length, Endian.little);
  b.add(head.buffer.asUint8List());
  var offset = 6 + 16 * frames.length;
  for (final MapEntry(key: px, value: png) in frames.entries) {
    final e = ByteData(16)
      ..setUint8(0, px >= 256 ? 0 : px)
      ..setUint8(1, px >= 256 ? 0 : px)
      ..setUint16(4, 1, Endian.little)
      ..setUint16(6, 32, Endian.little)
      ..setUint32(8, png.length, Endian.little)
      ..setUint32(12, offset, Endian.little);
    b.add(e.buffer.asUint8List());
    offset += png.length;
  }
  for (final png in frames.values) {
    b.add(png);
  }
  return b.toBytes();
}

void main() {
  testWidgets('generar iconos', (tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final icon = await _render(tester, 1024, const SoloKeyAppIcon(size: 1024));
    File('assets/logo/solokey_icon.png').writeAsBytesSync(icon);
    File('assets/logo/SoloKey.png').writeAsBytesSync(icon);

    // Adaptativo: el sistema recorta el fondo (#15171A en pubspec); la marca
    // va dentro de la zona segura (66 de 108).
    final fg = await _render(
      tester,
      1024,
      Center(
        child: SoloKeyMark(size: 1024 * 0.46, color: AppPalette.light.onInk),
      ),
    );
    File('assets/logo/solokey_adaptive_fg.png').writeAsBytesSync(fg);

    final frames = <int, Uint8List>{
      for (final px in _icoSizes)
        px: await _render(tester, px, SoloKeyAppIcon(size: px.toDouble())),
    };
    final ico = _ico(frames);
    File('assets/logo/SoloKey.ico').writeAsBytesSync(ico);
    File('windows/runner/resources/app_icon.ico').writeAsBytesSync(ico);
  });
}
