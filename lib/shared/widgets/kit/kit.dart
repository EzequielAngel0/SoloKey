/// Kit de componentes de Tinta y papel (DIS-2). Las pantallas de la v2 (carril
/// C) solo ensamblan estas piezas y leen tokens del tema; un color fijo en una
/// pantalla es un error de revisión (ADR-0013). Los textos llegan como
/// parámetros, ya traducidos.
///
/// Se ven todas en la galería de debug (DIS-3).
library;

export '../../../theme/app_palette.dart';
export '../../../theme/app_theme.dart' show AppTheme;
export '../../../theme/app_tokens.dart';
export 'bars.dart';
export 'copy_button.dart';
export 'credential_row.dart';
export 'desktop_panes.dart';
export 'notice.dart';
export 'paper_button.dart';
export 'paper_card.dart';
export 'safety_tone.dart';
export 'search_and_filters.dart';
export 'secret_field.dart';
export 'solokey_logo.dart';
export 'state_pill.dart';
export 'totp_code.dart';
