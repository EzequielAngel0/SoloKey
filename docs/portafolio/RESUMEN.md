# SoloKey — Textos listos para el portfolio / landing

> Copys en español e inglés, en tres tamaños (tarjeta, sección y hero de
> landing). Pegar y ajustar tono a gusto. Las capturas sugeridas están al final.

---

## Tarjeta de portfolio (1–2 líneas)

**ES** — Gestor de contraseñas local-first para Android y Windows con
sincronización P2P cifrada de extremo a extremo: tus secretos nunca tocan una
nube.

**EN** — Local-first password manager for Android and Windows with end-to-end
encrypted P2P sync: your secrets never touch a cloud.

---

## Sección de proyecto (portfolio)

**ES**

> **SoloKey** es un gestor de contraseñas que no negocia: cifrado real
> (Argon2id + AES-256-GCM), cero nube, cero cuentas, cero telemetría. La bóveda
> vive cifrada en tu dispositivo y se sincroniza directamente entre tu PC y tu
> celular por la red local, con cifrado de extremo a extremo (X25519 + delta
> sync con resolución de conflictos determinista). Incluye autenticador TOTP,
> archivos seguros cifrados, auditoría de salud de contraseñas (con
> verificación de filtraciones por k-anonymity), autofill nativo en Android,
> companion de escritorio con bandeja/atajos/command palette, y desbloqueo del
> PC aprobado desde el celular. 510 tests automatizados y piso de cobertura
> obligatorio en CI.
>
> *Flutter · Dart · Riverpod · Drift (SQLite) · Criptografía (Argon2id,
> AES-256-GCM, X25519) · WebSockets · Win32*

**EN**

> **SoloKey** is a password manager that refuses to compromise: real
> cryptography (Argon2id + AES-256-GCM), zero cloud, zero accounts, zero
> telemetry. The vault lives encrypted on your device and syncs directly
> between your PC and phone over the local network, end-to-end encrypted
> (X25519 + delta sync with deterministic conflict resolution). It ships a
> built-in TOTP authenticator, encrypted secure files, a password-health audit
> (with k-anonymity breach checks), native Android autofill, a desktop
> companion with tray/shortcuts/command palette, and phone-approved desktop
> unlock. 510 automated tests with a mandatory coverage floor in CI.
>
> *Flutter · Dart · Riverpod · Drift (SQLite) · Cryptography (Argon2id,
> AES-256-GCM, X25519) · WebSockets · Win32*

---

## Hero de landing page

**ES**

- **Titular:** Tus contraseñas. Tus dispositivos. Punto.
- **Subtítulo:** SoloKey guarda tu bóveda cifrada en tu propio dispositivo y la
  sincroniza directo entre tu PC y tu celular — sin nube, sin cuentas, sin
  rastreo.
- **CTA:** Descargar para Windows · Descargar APK para Android

**EN**

- **Headline:** Your passwords. Your devices. Period.
- **Subtitle:** SoloKey keeps your encrypted vault on your own device and syncs
  it directly between your PC and your phone — no cloud, no accounts, no
  tracking.
- **CTA:** Download for Windows · Download Android APK

### Bullets de features para la landing (ES)

- 🔐 **Cifrado de grado serio** — Argon2id + AES-256-GCM; la clave solo vive en
  RAM y se borra al bloquear.
- 🔄 **Sync sin nube** — PC ↔ celular por tu red local, cifrado de extremo a
  extremo. Nada sale de tu casa.
- 🛡️ **Todo en uno** — contraseñas, TOTP 2FA, llaves SSH, archivos cifrados y
  auditoría de salud con aviso de filtraciones.
- 📵 **Privacidad por defecto** — sin cuentas, sin telemetría, sin anuncios;
  las funciones que tocan internet son opt-in y anónimas.
- 💻 **Escritorio de verdad** — bandeja del sistema, Windows Hello, atajos
  globales, command palette y desbloqueo aprobado desde el celular.

---

## Capturas sugeridas (en este orden)

1. Bóveda (home móvil) con carpetas y buscador.
2. Detalle de credencial TOTP con el código en vivo.
3. Pantalla de Sincronizar en escritorio: QR + dispositivos conectados +
   resumen "qué se sincronizó".
4. Auditoría de seguridad con el score.
5. Companion de escritorio (master-detail + command palette).
6. Archivos seguros con búsqueda y notas.

> Consejo: usa datos de demostración (bóveda de prueba), nunca la bóveda real,
> y verifica que ninguna captura muestre secretos ni códigos TOTP válidos.
