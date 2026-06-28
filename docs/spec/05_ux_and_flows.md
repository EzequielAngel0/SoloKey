# Flujos de Usuario y Decisiones de UX (UX & Flows)

Este documento registra las decisiones arquitectónicas sobre la experiencia de usuario y los flujos críticos de la aplicación, para garantizar consistencia y seguridad al mismo tiempo.

## 1. Creación y Edición de Credenciales
- **Generación in-situ:** El Generador de Contraseñas no es una pantalla aislada dentro del flujo de creación. Está completamente integrado dentro del formulario de la credencial (ej. expandido bajo el campo de texto de la contraseña, mostrando sliders de longitud y opciones de caracteres). 
- **Inmediatez:** La contraseña generada se inserta de forma automática en el formulario y puede ser copiada al portapapeles inmediatamente sin romper el flujo de alta.

## 2. Flujo de Desbloqueo y Biometría (Unlock Screen)
- **Falsa Positiva:** Se evita lanzar un *prompt* biométrico al usuario de forma nativa a menos que este lo haya habilitado explícitamente en la configuración de la Bóveda (`AppSecuritySettings.biometricEnabled`).
- **Auto-Prompting:** Si la biometría está configurada como *Activa* durante el último guardado de preferencias, la pantalla de "UnlockScreen" intentará desencadenar el lector de huellas o rostro automáticamente al inicializarse la vista.
- **Fallback:** En caso de no estar activa en la configuración, se mostrará igualmente el botón de "Usar Biometría" como una opción manual, adyacente al método maestro de desbloqueo (Contraseña).
- **Prevención de Bucles:** Un usuario que cancela el prompt automático regresará fluidamente al método de ingreso por texto; no se forzará un reintento a menos que pulse el botón dedicado.
