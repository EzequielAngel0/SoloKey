# Política de Privacidad — SoloKey

**Última actualización:** 18 de julio de 2026

> ⚠️ **Nota para el autor (no publicar):** este documento es una plantilla
> redactada a partir del comportamiento real de la app en su versión 1.0.0.
> Revísala (idealmente con asesoría legal de tu jurisdicción), completa los
> campos entre corchetes y elimínale esta nota antes de subirla a la landing.
> Si en el futuro agregas analytics, crash reporting o descargas con registro,
> esta política debe actualizarse ANTES de activar esas funciones.

---

## Resumen en una línea

SoloKey no recopila, no transmite y no vende ningún dato tuyo. Tu bóveda vive
cifrada en tus dispositivos y solo en tus dispositivos.

## 1. Quiénes somos

SoloKey es una aplicación desarrollada por **Ángel Ezequiel Barbosa Lomelí**
("el desarrollador"). Contacto: **[CORREO DE CONTACTO]**.

## 2. Qué datos recopilamos

**Ninguno.** SoloKey:

- No requiere crear una cuenta ni proporcionar datos personales.
- No incluye telemetría, analytics, identificadores de publicidad ni rastreo.
- No envía tu bóveda, tus contraseñas ni tus archivos a ningún servidor del
  desarrollador ni de terceros. No existe ningún servidor de SoloKey.

## 3. Dónde viven tus datos

- Toda tu información (credenciales, códigos TOTP, archivos seguros, ajustes)
  se guarda **localmente** en tu dispositivo, cifrada con AES-256-GCM. La
  clave se deriva de tu contraseña maestra con Argon2id y nunca se almacena.
- El desarrollador **no puede** acceder a tu bóveda ni recuperarla. Si olvidas
  tu contraseña maestra y tu código de recuperación, los datos son
  irrecuperables por diseño.

## 4. Funciones que usan la red (y qué viaja exactamente)

SoloKey funciona completamente sin internet. Las únicas funciones que tocan la
red son las siguientes, y solo si tú las usas o activas:

| Función | ¿Activada por defecto? | Qué viaja y a dónde |
| :--- | :--- | :--- |
| **Sincronización P2P** entre tus dispositivos | Solo si emparejas dispositivos | Tus datos viajan **directamente entre tu PC y tu celular por tu red local**, cifrados de extremo a extremo (X25519 + AES-256-GCM). Nunca pasan por internet ni por servidores de nadie. |
| **Verificación de filtraciones** (Have I Been Pwned) | **No** (opt-in) | Solo un **prefijo anónimo de 5 caracteres** del hash SHA-1 de cada contraseña se envía a `api.pwnedpasswords.com` (técnica de k-anonymity). Tu contraseña completa nunca sale del dispositivo y el servicio no puede reconstruirla. |
| **Iconos de sitios (favicons)** | **No** (opt-in) | Si lo activas, se solicita el favicon del dominio guardado al servicio `google.com/s2/favicons`. Ese proveedor recibe el **dominio** del sitio (nunca usuarios ni contraseñas). |

Al usar las funciones de HIBP o favicons, las solicitudes quedan sujetas a las
políticas de privacidad de esos terceros (Have I Been Pwned y Google,
respectivamente). SoloKey no les añade ningún identificador tuyo.

## 5. Permisos que solicita la app

- **Biometría / Windows Hello:** para desbloquear la bóveda. La validación la
  hace el sistema operativo; SoloKey nunca ve ni almacena tu huella o rostro.
- **Cámara (Android):** solo para escanear códigos QR (emparejamiento y TOTP).
  Las imágenes no se guardan ni se envían.
- **Notificaciones:** recordatorios de rotación de contraseñas y avisos de
  sincronización. Se generan localmente.
- **Red local:** exclusivamente para la sincronización P2P entre tus propios
  dispositivos.

## 6. Sitio web / landing

La página de descarga de SoloKey es un sitio estático. No usa cookies propias
ni analytics. **[AJUSTAR SI EL HOSTING REGISTRA LOGS O SI AGREGAS ANALYTICS:
indicar proveedor, qué registra (p. ej. IP en logs del servidor) y su
finalidad.]**

## 7. Menores de edad

SoloKey no recopila datos de ningún usuario, incluidos menores de edad.

## 8. Cambios a esta política

Publicaremos cualquier cambio en esta misma página, actualizando la fecha del
encabezado. Los cambios sustanciales se destacarán en las notas de la versión.

## 9. Contacto

Preguntas sobre privacidad: **[CORREO DE CONTACTO]**.
