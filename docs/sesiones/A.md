# Carril A · Núcleo (cripto, bóveda, BD, sync en Rust)

Reglas y plantilla: [`README.md`](README.md). Plan: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md). Decisiones:
[ADR-0008](../adr/0008-nucleo-en-rust.md) (núcleo Rust), [0009](../adr/0009-formato-de-boveda-v2.md) (formato),
[0010](../adr/0010-sync-v2-canal-cifrado.md) (sync), [0011](../adr/0011-pruebas-e2e-principal.md) (pruebas),
[0012](../adr/0012-todo-en-podman.md) (Podman).

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | NUC-5 | Passkeys reales (WebAuthn, proveedor de Credential Manager en Android) | XL | ⊘ después de la v2.0.0 | [`../seguridad/WEBAUTHN.md`](../seguridad/WEBAUTHN.md) |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| D | `cargo-expand` en la etapa Rust de `solokey-build`: `rust/puente.ps1` lo instala en cada corrida | Regenerar el puente rápido |
| C | Tras migrar, si el almacén tiene `recovery_reset_needed` (`kRecoveryResetNeeded`), pedir generar un código nuevo (`RecoveryService.generateRecoveryCode`) y borrar la marca; textos de la migración (avance, éxito, error con la v1 intacta) | Que la bóveda migrada vuelva a tener código |
| C | El aviso agrupado de rotación abre la app (`NotificationTapKind.openApp`): mostrar dentro, tras desbloquear, cuáles toca cambiar | Decisión del dueño 2026-11-20: el aviso de fondo no lleva nombres |
| E | Las E2E necesitan `--dart-define=SOLOKEY_DATA_DIR` (ya en el runner, `tests.yml` y `tool/build.ps1 -E2e`); sin ella, las que borran se omiten. CAL-5 puede quitar el respaldo de la bóveda real del runner | Ya no tocan la bóveda real |
| E | Los vectores de la v1 se regeneran desde `main` (`generar_vectores.dart` salió de develop con drift) | Saberlo si se rehacen |
| C | Pantalla del QR: el token es de un uso y caduca a los 10 min; tras `pairing_token_used` o al caducar, botón "QR nuevo" (`startServer` otra vez) para otro celular | Emparejar un segundo celular (NUC-3) |
| C | Pasar a l10n `kPeerV1Message` y `kPeerV2Message` (`pairing_payload.dart`) y avisar tras actualizar que hay que volver a emparejar (la v2 borra el emparejamiento de la v1) | Aviso entre v1 y v2 (NUC-3) |
| D | El volumen `solokey-build-target` compartido + `tar` que conserva fechas: cargo puede dar por frescas fuentes cambiadas si otra sesión compiló después. Hoy: `touch` a los `.rs` cambiados antes de `tool/build.ps1 -Nucleo` | Que `rust/dist` no salga viejo ("Content hash ... different") |

## No reabre

| Qué | Por qué |
|---|---|
| Nube o servidor propio para sincronizar | Local-first es la promesa del producto (ADR-0001) |
| NUC-0, prototipo comparativo de R1 | El dueño eligió R1 directo (2026-11-15) |
| NUC-4, endurecer el borrado en Dart | Era para R0; con el núcleo en Rust no aplica |
| `rustup` en el host | Todo Rust en Podman (ADR-0012) |
