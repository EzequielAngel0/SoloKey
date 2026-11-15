<#
.SYNOPSIS
  Genera los vectores de prueba de la boveda v1 (CAL-2) dentro de Podman.

.DESCRIPTION
  Corre tool/vectores_v1/generar_vectores.dart (codigo real de la v1) en la imagen de
  CI de Linux (tool/ci-linux.ps1, misma version de Flutter que tests.yml). Dentro del
  contenedor la boveda real del duenio no existe: el almacen seguro va en memoria y la
  BD y los archivos se escriben en vectores/v1 (montado como /out).
  Explicacion de la salida: vectores/v1/LEEME.md. Archivo en ASCII (PowerShell 5.1).

.EXAMPLE
  .\tool\vectores_v1\generar.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$out = Join-Path $repo 'vectores\v1'

& (Join-Path $repo 'tool\ci-linux.ps1') -Salida $out `
  -Comando 'VECTORES_SALIDA=/out flutter test tool/vectores_v1/generar_vectores.dart'
if ($LASTEXITCODE -ne 0) { Write-Host 'FALLO la generacion de vectores' -ForegroundColor Red; exit 1 }
Write-Host 'OK: vectores en vectores/v1 (revisa git diff antes de commitear)' -ForegroundColor Green
