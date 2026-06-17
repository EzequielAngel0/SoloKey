import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RightPaneMode {
  none,
  details,
  create,
  edit,
}

// 0: Credenciales, 1: Carpetas, 2: Favoritas, 3: Auditoría, 4: Ajustes, 5: Sincronizar
final desktopSelectedNavigationProvider = StateProvider<int>((ref) => 0);

final desktopSelectedCredentialIdProvider = StateProvider<String?>((ref) => null);

final desktopRightPaneModeProvider = StateProvider<RightPaneMode>((ref) => RightPaneMode.none);

// Track the folder ID selected in folders view for desktop details
final desktopSelectedFolderIdProvider = StateProvider<String?>((ref) => null);
