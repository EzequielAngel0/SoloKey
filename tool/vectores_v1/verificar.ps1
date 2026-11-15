<#
.SYNOPSIS
  Comprueba vectores/v1 con una implementacion independiente (Python) dentro de Podman.

.DESCRIPTION
  Rederiva las claves con Argon2id, descifra la BD, el codigo de recuperacion, los archivos
  seguros, el doble cifrado y la exportacion, y compara con vectores.json. Sin Dart: prueba
  que otro lenguaje (el nucleo Rust) puede leer la boveda v1 con lo documentado.
  Contenedor desechable solokey-verificar-vectores. Archivo en ASCII (PowerShell 5.1).

.EXAMPLE
  .\tool\vectores_v1\verificar.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$v = (Join-Path $repo 'vectores\v1') -replace '\\', '/'
$s = (Join-Path $repo 'tool\vectores_v1') -replace '\\', '/'

& podman run --rm --name solokey-verificar-vectores -v "${v}:/v:ro" -v "${s}:/s:ro" `
  docker.io/library/python:3.12-slim bash -c `
  'pip install -q --disable-pip-version-check argon2-cffi==23.1.0 cryptography==44.0.2 2>&1 | grep -v WARNING; python -I /s/verificar.py'
if ($LASTEXITCODE -ne 0) { Write-Host 'FALLO la verificacion de vectores' -ForegroundColor Red; exit 1 }
Write-Host 'OK: vectores/v1 se leen sin Dart' -ForegroundColor Green
