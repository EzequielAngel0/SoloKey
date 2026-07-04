# WebAuthn / FIDO2 real — evaluacion de esfuerzo y plan por fases

> Origen: `docs/prompts/51_archivos_passkeys.md` ("Feature grande: WebAuthn/FIDO2
> real via Windows Hello / Android Credential Manager, no solo respaldo").
> Este documento **evalua** el esfuerzo y propone un plan; **no** se implemento
> en la pasada del prompt 51 (guardarrail: no romper cripto/persistencia/sync).

## 1. Estado actual (que hay hoy)

- `CredentialType.passkey` + `PasskeyMetadata` (rpId, credentialId, verificacion…).
- La pantalla `features/passkeys/presentation/passkeys_screen.dart` **solo lista
  y gestiona metadatos cifrados** (respaldo). La "clave privada" almacenada en
  `Credential.password` es un handle opaco: **no se firma ninguna ceremonia**.
- Es decir: SoloKey **no es** todavia un autenticador FIDO2 ni un cliente RP.
  Es un cuaderno cifrado de "aqui registre una passkey".

## 2. Que implica "WebAuthn real" (y por que es grande)

WebAuthn define dos ceremonias entre un **Relying Party (RP)** y un
**authenticator**:

- **Registro** (`navigator.credentials.create`): el authenticator genera un par
  de llaves (normalmente **ES256 / P-256**, a veces **EdDSA**), guarda la privada
  y devuelve la publica + un `attestationObject` (CBOR/COSE).
- **Autenticacion** (`navigator.credentials.get`): el authenticator **firma** un
  `clientDataHash` con la privada -> `assertion` (authenticatorData + signature).

Hacer esto "de verdad" exige, ademas de la criptografia (ECDSA P-256, COSE keys,
codificacion **CBOR**, `authenticatorData` con RP ID hash + flags + counter):

1. **Decidir el rol del producto** (ver §3) — es la decision clave.
2. **Codigo nativo por plataforma** — Flutter no expone estas APIs; hace falta
   Kotlin (Android) y FFI/C++ (Windows) tras un `MethodChannel`.
3. **Garantias de seguridad** — la privada **nunca** sale en claro; idealmente
   vive en hardware (StrongBox/TPM); manejo de `signCount` anti-clonacion;
   User Verification (biometria/PIN) real ligada a la firma.

## 3. Dos direcciones de producto (no son lo mismo)

| | A. Cliente RP | B. Proveedor / autenticador |
|---|---|---|
| Que hace | Usa passkeys del **sistema** para loguear en servicios | SoloKey **crea, guarda y firma** con sus propias passkeys (como 1Password/Bitwarden) |
| Android | `androidx.credentials` **GetCredential** (API 28+) | **CredentialProviderService** (`androidx.credentials.provider`, **API 34+**) |
| Windows | `webauthn.dll` (`WebAuthNAuthenticatorGetAssertion`) via FFI | **Plugin authenticator** (Win11 **24H2+**, Eap/plugin API — muy nuevo) |
| Valor para un gestor | Bajo (el navegador/OS ya lo hace) | **Alto** — es la funcion diferenciadora |
| Esfuerzo | Medio | **Muy alto** (multi-mes, seguridad critica) |

**Conclusion:** lo que aporta valor a un password manager es **B (proveedor)**,
y es justamente lo mas caro y de APIs mas recientes. La opcion A es relativamente
barata pero casi redundante con lo que ya hacen el navegador y el OS.

## 4. Riesgos y restricciones

- **Superficie nativa grande** por plataforma; poco reutilizable entre Android y
  Windows; iOS/macOS (ASAuthorization / ASCredentialProviderExtension) quedaria
  como tercera implementacion.
- **Seguridad critica**: un bug filtra o clona una llave FIDO2 -> anula la ventaja
  de las passkeys. Debe respetar el **dominio ciego**: toda la cripto en la capa
  data/infra (nuevo `IPasskeyAuthenticator` implementado con canal nativo), nunca
  en presentation/domain.
- **Sync E2EE**: si SoloKey es proveedor, las **privadas de passkey** entrarian al
  sync P2P; hay que cifrarlas con el mismo sobre AES-256-GCM y decidir politica de
  `signCount` entre dispositivos (riesgo de falsos positivos de clonacion).
- **Requisitos de OS altos** (Android 14 / Windows 11 24H2) recortan el publico
  hoy; conviene degradar con elegancia al modo "respaldo" actual.
- **Attestation**: la mayoria de RPs acepta `none`; hacer packed/self-attestation
  correcto es trabajo extra si algun RP la exige.

## 5. Plan por fases (incremental, cada fase entregable y con gates verdes)

### Fase 0 — Preparacion sin nativo (bajo esfuerzo)
- Endurecer el **respaldo** actual (ya iniciado en el prompt 51: kit compartido,
  a11y, copiar credential ID, fecha relativa).
- Introducir la abstraccion `IPasskeyAuthenticator` en `features/passkeys/domain`
  con `Future<PasskeyRegistration> register(...)` y
  `Future<PasskeyAssertion> assert(...)`, y una impl `UnsupportedPasskeyAuthenticator`
  que hoy lanza `UnsupportedError`. Deja el sitio listo sin cambiar comportamiento.
- Tests unit del contrato (fakes).

### Fase 1 — Cliente RP en Android (medio)
- `MethodChannel` `com.solokey/webauthn` + Kotlin usando `CredentialManager`
  (`GetCredentialRequest` con `GetPublicKeyCredentialOption`).
- Permite **usar** passkeys del sistema desde flujos propios de la app.
- Sin custodia de llaves propias todavia. Degradar si API < 28.

### Fase 2 — Proveedor Android (alto)  ← funcion diferenciadora
- `CredentialProviderService` (API 34+): registrar SoloKey como proveedor de
  passkeys del sistema.
- Generacion de par **ES256** en la capa infra (idealmente StrongBox), guardado de
  la privada **cifrada** con la sesion/master key, `authenticatorData` + firma,
  COSE/CBOR (evaluar `cbor`/`pointycastle` o via nativo).
- User Verification real (biometria) ligada a cada assertion. Manejo de `signCount`.
- Integracion con el **sync E2EE** de las privadas + politica de contador.

### Fase 3 — Windows (alto, API muy nueva)
- Corto plazo: cliente RP via `webauthn.dll` (FFI) para **usar** Windows Hello.
- Largo plazo: **plugin authenticator** de Win11 24H2 para ser proveedor (evaluar
  madurez/estabilidad de la API antes de comprometer).

### Fase 4 — iOS/macOS (diferido)
- `ASAuthorizationController` (cliente) y `ASCredentialProviderExtension`
  (proveedor). Tercera implementacion nativa; fuera del alcance actual del host.

## 6. Recomendacion

**No abordar B (proveedor real) en esta pasada.** Es un proyecto multi-mes,
nativo por plataforma, con APIs de OS muy recientes y seguridad critica que toca
el sync E2EE. El retorno de A (cliente RP) es bajo porque el OS ya cubre ese caso.

Accion recomendada ahora: **quedarse en Fase 0** — mantener el respaldo cifrado
(ya endurecido) y dejar plantada la abstraccion `IPasskeyAuthenticator` para que
Fase 1/2 no requieran refactor de la UI. Reevaluar Fase 2 cuando Android 14+ tenga
penetracion suficiente y la API de proveedor de Windows este estable.
