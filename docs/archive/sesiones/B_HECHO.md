# Carril B · Hecho

Lo terminado del carril B ([`../../sesiones/B.md`](../../sesiones/B.md)), una o dos líneas por ID. Detalle técnico en
[`../../../CHANGELOG.md`](../../../CHANGELOG.md).

| ID | Qué | Fecha | Verificado |
|---|---|---|---|
| DIS-1 | Tokens Tinta y papel por rol (claro y oscuro, AA), `AppTheme` reescrito, `app_tokens.dart`, claro + oscuro + sistema, Atkinson Hyperlegible Next y Mono a pesos fijos; fuera `app_colors.dart`, dim, OLED y colores de tipo (alias v1 hasta las PAN) | 2026-11-20 | analyze 0, 497 pruebas, cobertura 63.6 %; en la app, con la galería (DIS-3) |
| DIS-2 | Kit liso en `lib/shared/widgets/kit/` (`kit.dart`): botones, campo y texto secreto, fila de credencial con copiar a la vista, tarjeta, aviso y pastilla de estado, búsqueda y filtros, barras del celular, tres paneles de escritorio, TOTP | 2026-11-20 | analyze 0, 480 pruebas; claro, oscuro, 100 y 200 %, celular y escritorio sin desbordes (capturas de prueba, no versionadas) |
| DIS-3 | Galería del kit en `lib/main_galeria.dart` (solo debug, punto de entrada aparte en vez de ruta oculta): paleta con hex, todos los componentes, tema, letra 100/150/200 % y celular o escritorio | 2026-11-20 | analyze 0, 480 pruebas; sin errores en claro, oscuro, 100 y 200 %; corriendo en Windows para el dueño |
| DIS-5 | Fuera las 22 vibraciones, el shimmer de carga (ahora un indicador quieto) y la animación escalonada (DEC-5) | 2026-11-20 | analyze 0, 479 pruebas (se borró la del shimmer) |
