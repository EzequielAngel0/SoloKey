import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'shared/gallery/kit_gallery.dart';

/// Galería del kit de Tinta y papel (DIS-3), solo en debug:
///
/// `flutter run -d windows -t lib/main_galeria.dart`
///
/// No abre la bóveda ni la sesión: solo pinta los componentes. La build release
/// sale de `lib/main.dart`, que no importa este archivo.
void main() {
  if (!kDebugMode) {
    throw StateError('La galería solo existe en la build debug.');
  }
  runApp(const KitGalleryApp());
}
