# ADR-0004: Un solo código Flutter para Android y Windows

Estado: Vigente (2026-07) · Decide: el dueño

## Contexto
La app nació en Android (marzo de 2026). En junio hizo falta el companion de Windows: misma bóveda, misma sync, atajos y bandeja.

## Decisión
- **Una sola app Flutter** (`password_manager`) para las dos plataformas; lo propio de cada una vive detrás de interfaces en
  `lib/core/` y se elige al arrancar (`Platform.isWindows`, `Platform.isAndroid`).
- Lo nativo va por plugins (autofill y `FLAG_SECURE` en Android; bandeja, instancia única, Windows Hello y atajos en Windows).
- Windows se entrega como **instalador Inno Setup** (`build_release.ps1 -Target inno`), no como `.exe` suelto.

## Consecuencias
- Una corrección de dominio o cripto llega a las dos plataformas a la vez; las pruebas unitarias cubren ambas.
- El escritorio necesita su propio diseño (master-detail, teclado), no la pantalla del celular estirada.
- macOS, Linux e iOS son posibles, pero diferidos sin hardware para probarlos (PLA-2, [`../publicacion/IOS.md`](../publicacion/IOS.md)).

## Alternativas descartadas
App nativa por plataforma (doble código y doble cripto), Electron o Tauri para el escritorio (otro stack, otra implementación
del cifrado). La v2 puede mover el **núcleo** a Rust (DEC-1) sin cambiar esta decisión: la interfaz seguiría en Flutter.
