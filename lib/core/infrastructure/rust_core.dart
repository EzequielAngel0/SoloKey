import 'package:flutter/foundation.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import 'rust/frb_generated.dart';

Future<void>? _loading;

/// Carga el nucleo Rust (ADR-0008) una vez por isolate; lo llama `configureDependencies`.
///
/// En release solo se busca donde lo empaqueta el build (junto al .exe en Windows, en el APK en Android).
/// En debug y en `flutter test` tambien en `rust/dist/` del repo, donde lo deja
/// `.\tool\build.ps1 -Nucleo -Salida rust\dist`.
Future<void> initRustCore() => _loading ??= _load();

Future<void> _load() async {
  if (RustLib.instance.initialized) return;
  final lib = await loadExternalLibrary(
    const ExternalLibraryLoaderConfig(
      stem: 'solokey_core',
      ioDirectory: kReleaseMode ? null : 'rust/dist/',
      webPrefix: null,
    ),
  );
  await RustLib.init(externalLibrary: lib);
}
