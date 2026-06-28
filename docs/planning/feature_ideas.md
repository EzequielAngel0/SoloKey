# Posibles Mejoras y Futuras Características (SoloKey)

Este documento contiene un conjunto de ideas, expansiones funcionales y mecánicas avanzadas sugeridas para iteraciones futuras en el desarrollo de la aplicación. Representan adiciones lógicas que potenciarían a SoloKey para competir contra soluciones comerciales modernas.

## 🔐 1. Seguridad Avanzada y Biometría Estricta

*   **Autenticación en Interacciones Específicas:** Solicitar validación biométrica obligatoria (huella o Face ID) justo antes de permitir copiar una contraseña al portapapeles o revelar un campo sensible (`obscureText = false`).
*   **Soporte de Passkeys:** Permitir el almacenamiento integrado de FIDO2 / WebAuthn Passkeys utilizando las APIs nativas de Android (Credential Manager) e iOS (Authentication Services).
*   **Llaves Físicas (NFC/USB):** Soporte para YubiKey. Requerir el toque de una llave física NFC para descifrar la capa más profunda de la bóveda o actuar como 2FA maestro.
*   **Teclado Seguro Interno (Scrambled Keypad):** Un teclado en pantalla que aleatorice la posición de las teclas al momento de introducir el PIN maestro, protegiendo contra huellas térmicas o grabaciones de la pantalla.

## ☁️ 2. Exportación y Sincronización Local-First

*   **Exportación/Importación Segura Binaria:** Capacidad de empacar la base de datos completa de SQLite en un archivo cifrado propio (ej. `.vgvault`) con una contraseña desechable (distinta a la maestra) para poder transportarla entre dispositivos locales sin nubes.
*   **Exportación a Formatos Abiertos (CSV/JSON):** Permitir volcar los datos a CSV plano (con advertencia de extrema sensibilidad) para compatibilidad con migración a otros gestores comunes (Bitwarden, 1Password, etc.).
*   **Sincronización P2P / WiFi Local:** Mantener SoloKey como "Local-First" sincronizando bóvedas directamente por WiFi o Bluetooth entre el teléfono del usuario y su PC, sin pasar por servidores en la nube.

## 🌐 3. Integración con el Sistema Operativo

*   **Servicio de Autocompletado del SO (Autofill API):**
    *   **Android:** Integración con *AutofillService* para que SoloKey sugiera credenciales automáticamente cuando el usuario abra una app como Twitter o Netflix, o un formulario en el navegador web Chrome.
    *   **iOS:** Extensión de *AutoFill Credential Provider* para la misma funcionalidad en Safari o apps.
*   **Integración con Accesos Directos (Quick Settings / Tiles):** Botón nativo en la barra de ajustes de Android para bloquear inmediatamente la bóveda sin entrar a la aplicación.
*   **Widgets Nativos de Pantalla de Inicio:** Widget opaco que al pulsarlo pida huella e inicie inmediatamente en "Crear Credencial" o un contador interactivo para los TOTPs favoritos sin abrir de lleno la aplicación principal.

## 🔍 4. Auditoría Extendida

*   **Integración de API de Brechas (HaveIBeenPwned):** Función de auditoría activable (opt-in) que envíe anónimamente los 5 primeros caracteres del hash SHA-1 de las contraseñas guardadas (tecnología *k-Anonymity*) para verificar continuamente si alguna contraseña ha sido filtrada en internet.
*   **Historial de Contraseñas Anteriores:** Si un usuario cambia la contraseña de "Facebook" en 2026, mantener las contraseñas previas de 2025 o 2024 almacenadas automáticamente en un sub-campo oculto en caso de que alguien secuestre la cuenta vieja.

## 👥 5. Uso Compartido (Compartición Zero-Knowledge)

*   **"VaultDrop" o Compartición de Secretos Segura:** Sistema mediante código QR que contenga un enlace efímero cifrado para pasarle temporalmente la contraseña de Netflix a un familiar de a lado de forma segura.

## 🎨 6. Refinamiento en Categorías y Data

*   **Iconos Automáticos / Favicons:** Al ingresar un sitio web como `netflix.com`, que la aplicación descargue automáticamente (y almacene como BLOB binario) el favicon del logotipo del servicio, para darle un look mucho más corporativo a la bóveda visual.
*   **Etiquetas Combinadas (Tags):** Aparte de "Carpetas", permitir agrupar por etiquetas (`#Trabajo`, `#Streaming`, `#Bancos`) donde una misma credencial pueda tener más de una sola etiqueta a la vez.

---

## 🆕 7. Sugerencias revisadas (2026-06-28)

> Curadas tras revisar el código real. Se excluyen a propósito "Acceso de
> emergencia / herencia digital" y "Tipos de credencial con plantillas (tarjeta,
> identidad, banco…)" por decisión de producto: **no se manejará PII**.
> Lo ya implementado (autofill Android, teclado seguro, HaveIBeenPwned, favicons,
> import CSV, TOTP, carpetas, auditoría, recovery, anti-fuerza-bruta, backup
> programado, rotación, doble sobre, llaves SSH, sync P2P, WiFi-unlock, quick-fill,
> hotkeys, autostart, archivos seguros) no se repite aquí.

### 🖥️ Escritorio
*   **Extensión de navegador (Chrome/Edge/Firefox) — máxima prioridad:** el SO de
    escritorio no expone autofill; hoy solo hay Quick-Fill por portapapeles. Una
    extensión que hable con la app por el WebSocket local (mismo canal del sync)
    daría autocompletado real en webs. Es lo que más acerca SoloKey a
    Bitwarden/1Password en PC.
*   **Auto-Type estilo KeePass:** en vez de copiar al portapapeles, simular
    pulsaciones en el campo enfocado (`user{TAB}pass{ENTER}`). Más seguro que el
    clipboard; complementa el `Ctrl+Shift+L` existente.
*   **Overlay tipo Spotlight:** ventana flotante de búsqueda rápida sobre el hotkey
    global, sin abrir la app entera (ya anotado como mejora futura en el roadmap).
*   **Recordar tamaño/posición de ventana + multi-monitor** y **modo portable**
    (bóveda junto al `.exe` en USB).

### 📱 Móvil (Android)
*   **Passkeys reales vía Credential Manager:** hoy es "respaldo" sin firma
    WebAuthn (gap de la Fase 12). Cierra la promesa de passkeys.
*   **Widget de pantalla de inicio + Quick Settings tile:** widget de TOTP
    favoritos y un botón de "bloquear bóveda ya". Alto valor, bajo esfuerzo.
*   **Importar QR de migración de Google Authenticator** (`otpauth-migration://`):
    migración masiva de TOTPs en un escaneo.
*   **PIN de coacción (duress):** un segundo PIN que abre una bóveda señuelo o
    dispara wipe. Encaja con el `WipeVaultUseCase` existente.

### 🔗 Ambas / transversal
*   **Etiquetas (tags multi-categoría):** complemento a carpetas; una credencial
    con `#trabajo #banca`. (Reitera el §6, sigue pendiente.)
*   **Compartición segura "VaultDrop":** pasar una credencial por QR/enlace
    efímero cifrado, reutilizando el canal E2EE del sync. (Reitera el §5.)
*   **YubiKey / FIDO2 como 2FA del desbloqueo:** NFC en móvil, USB en PC.
*   **Monitoreo proactivo de brechas:** hoy HaveIBeenPwned es manual/opt-in;
    convertirlo en chequeo programado que **notifique** (reutiliza
    `NotificationService` + workmanager ya existentes).
*   **Ocultar / reorganizar credenciales en la lista (solicitado por el usuario):**
    cuando hay muchas credenciales, el scroll se vuelve tedioso. Opciones
    combinables:
    1.  **Reordenar manualmente** con arrastrar-y-soltar y un campo persistido
        `sortOrder` (o `ReorderableListView`), respetando el orden elegido.
    2.  **Ocultar / archivar**: bandera `isHidden`/`isArchived` para sacar
        credenciales poco usadas de la lista principal, con una vista "Ocultas"
        para verlas/restaurarlas. Migración Drift (nueva columna) + filtro en el
        repositorio + toggle en la barra de la credencial.
    3.  **Anclar (pin)** las más usadas arriba (complementa Favoritos).
