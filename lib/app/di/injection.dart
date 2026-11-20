import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../core/infrastructure/rust_core.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // El nucleo Rust va antes que todo: SecurityService lo usa (NUC-1).
  await initRustCore();
  getIt.init();
}
