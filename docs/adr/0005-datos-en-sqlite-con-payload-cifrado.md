# ADR-0005: Datos en SQLite (drift) con el payload cifrado en un BLOB

Estado: Vigente en la v1 (2026-03); en la v2 la reemplaza ADR-0009 · Decide: el dueño

## Contexto
La bóveda necesita listar, buscar y ordenar rápido sin descifrar todo, y migrar el esquema entre versiones sin perder datos.

## Decisión
- **drift sobre SQLite** (`vault_guard_db`, versión 10 hoy): una fila por registro, con los metadatos mínimos en claro (id, tipo,
  carpeta, fechas, orden, oculto) y **todo lo demás en un BLOB cifrado** ([ADR-0003](0003-cifrado-de-la-boveda.md)).
- La configuración y las llaves (sal, `K_sync`, banderas de seguridad) van en **`flutter_secure_storage`** (Keystore en Android,
  DPAPI en Windows), no en la base.
- Cada cambio de esquema es una migración de drift con su prueba.

## Consecuencias
- La búsqueda por texto descifra en memoria lo necesario; con miles de registros habría que medirla (sin medir todavía).
- Quien roba el archivo ve cuántos registros hay, de qué tipo y cuándo cambiaron, pero no su contenido.
- El nombre `vault_guard_db` viene del nombre viejo del proyecto; cambiarlo es una migración, no un renombre.

## Alternativas descartadas
SQLCipher (base cifrada entera: otra dependencia nativa por plataforma y la búsqueda igual tendría la clave en RAM), Hive o
archivos JSON (sin migraciones ni consultas).
