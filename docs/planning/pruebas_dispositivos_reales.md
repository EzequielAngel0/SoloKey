# ✅ Guía de pruebas en dispositivos reales — R1 / M1 / M3 (+ regresiones)

> **Por qué existe este documento:** R1 (reconexión sin QR), M1 (sync continua)
> y M3 (push de aprobación de login) están **implementados y con tests
> unitarios/de widget en verde**, pero el flujo cruzado PC↔celular **no puede
> probarse desde un solo equipo**. Esta es la checklist para validarlos con un
> PC Windows y un celular Android **en la misma red Wi-Fi**. Hasta completarla,
> esos tres items siguen 🟦 en `pendientes_y_bugs.md`.
>
> Requisitos: instalar en el PC el `SoloKey-<ver>-setup.exe` y en el celular el
> `SoloKey-<ver>-universal.apk` de `dist/` (generados con `build_release.ps1`).
> Mismo Wi-Fi, sin aislamiento de AP (AP isolation) en el router, y sin VPN
> activa en ninguno de los dos.

## 0. Preparación (una sola vez)

- [ ] PC: instalar y abrir SoloKey, crear/desbloquear la bóveda.
- [ ] Celular: instalar el APK, crear/desbloquear la bóveda.
- [ ] PC: al iniciar el servidor de sync por primera vez, aceptar la regla de
      firewall si Windows la pide (o crearla manualmente para el rango de
      puertos 8283+ si el emparejamiento falla).

## 1. B2 — Emparejamiento inicial por QR (regresión)

- [ ] PC: abrir **Sincronizar** → debe aparecer el **QR** (aunque el mDNS no
      esté disponible: el fallo de Bonjour ya no bloquea el QR).
- [ ] Verificar que la IP mostrada bajo el QR es la del adaptador Wi-Fi/Ethernet
      real (no una IP de VPN/WSL/VirtualBox). Si hay varias, elegir la correcta.
- [ ] Celular: **Sincronizar → Escanear QR** → escanear → debe quedar
      **Emparejado** y aparecer el dispositivo en la lista del PC.
- [ ] Celular: tocar **Sincronizar Bóveda** → los cambios llegan y la bóveda del
      PC se **auto-actualiza sin cerrar/abrir** (fix `1b740da`).
- [ ] Ambos: revisar la tarjeta **"Última sincronización"** con el resumen de
      qué se sincronizó (creadas/actualizadas/borradas).

## 2. R1 — Reconexión sin QR (handshake resume)

- [ ] Con el emparejamiento del paso 1 hecho, **cerrar ambas apps**.
- [ ] Abrir el PC (el servidor residente arranca solo — G1).
- [ ] Abrir el celular → **Sincronizar** → debe reconectar **sin pedir QR**
      (resume por HMAC challenge con la K_sync persistida).
- [ ] Repetir tras reiniciar el router (cambia la IP del PC): el celular debe
      redescubrir o permitir reintentar sin re-emparejar.

## 3. M1 — Sincronización continua

- [ ] Con ambas apps abiertas y conectadas (paso 2), **crear una credencial en
      el celular** → en ≤ ~60 s debe aparecer en el PC **sin tocar nada**.
- [ ] **Editar una credencial en el PC** → debe llegar sola al celular.
- [ ] Apagar el Wi-Fi del celular 1 minuto y reencenderlo → la conexión debe
      **auto-reconectar** (heartbeat + retry) y el siguiente cambio sincronizar.
- [ ] Notificación nativa "N cambios sincronizados" al aplicar un delta en el
      dispositivo receptor; al tocarla abre Sincronizar.
- [ ] Conflicto: editar la MISMA credencial en ambos lados estando
      desconectados, reconectar → gana la edición más reciente (LWW) sin
      duplicados.

## 4. M3 — Aprobación de login desde el celular (push local, sin FCM)

- [ ] PC: bloquear la bóveda (o abrir la app bloqueada). En la pantalla de
      desbloqueo, tocar **"Desbloquear desde el celular"** (pedir aprobación).
- [ ] Celular (app abierta o en segundo plano reciente, conectada por resume):
      debe sonar/aparecer la **notificación local** de aprobación.
- [ ] Tocar la notificación → se abre Sincronizar → aprobar con **biometría** →
      el PC se **desbloquea solo** (el DUK viaja por el canal E2EE; la
      contraseña maestra nunca sale del celular).
- [ ] Negativo: con la app del celular **totalmente cerrada**, la petición NO
      llega (limitación aceptada sin FCM) y el PC muestra "sin dispositivos".

## 5. M2 — Windows Hello (regresión)

- [ ] PC con PIN/Hello configurado: en la pantalla de desbloqueo aparece
      **"Usar Windows Hello"** como acción primaria y desbloquea con PIN,
      huella o rostro.

## 6. WiFi-unlock clásico (PULL, regresión)

- [ ] PC bloqueado con el servidor corriendo; celular → Sincronizar →
      **Desbloquear PC** → biometría → el PC se desbloquea.

## 7. B1 + icono (regresiones de escritorio)

- [ ] Cerrar la ventana del PC con la **X** (queda en bandeja) y volver a abrir
      desde el acceso directo → se **enfoca la instancia existente**; en el
      Administrador de tareas hay **UN solo** `solokey.exe`.
- [ ] La **barra de tareas** muestra el logo de SoloKey en el proceso vivo
      (fix `RelaunchIconResource`; si tras actualizar sigue genérico, anclar y
      desanclar el acceso directo una vez para refrescar la caché de iconos).

## Registro de resultados

| # | Prueba | Fecha | Resultado (✅/❌) | Notas |
| :-- | :--- | :--- | :--- | :--- |
| 1 | B2 emparejamiento QR | | | |
| 2 | R1 reconexión sin QR | | | |
| 3 | M1 sync continua | | | |
| 4 | M3 aprobación push | | | |
| 5 | M2 Windows Hello | | | |
| 6 | WiFi-unlock | | | |
| 7 | B1 + icono taskbar | | | |

> Al completar la tabla: actualizar `pendientes_y_bugs.md` (pasar R1/M1/M3 de
> 🟦 a ✅ o abrir bugs con lo encontrado) y el estado final de `CLAUDE.md`.
