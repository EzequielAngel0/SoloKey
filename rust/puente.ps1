# Regenera el puente Flutter <-> nucleo Rust (flutter_rust_bridge, ADR-0008) en Podman, con la imagen de
# tool/build.ps1 (solokey-build). Correrlo tras cambiar rust/solokey-core/src/api/.
# Escribe lib/core/infrastructure/rust/ y rust/solokey-core/src/frb_generated.rs; nada mas del arbol.
# Las librerias nativas (DLL y .so) salen aparte: .\tool\build.ps1 -Nucleo -Salida rust\dist
# Archivo en ASCII (PowerShell 5.1).
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$out = Join-Path $repo 'build\puente'
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Recurse -Force }

$cmd = 'flutter_rust_bridge_codegen generate && mkdir -p "$SALIDA/lib" "$SALIDA/src" && ' +
  'cp -r lib/core/infrastructure/rust/. "$SALIDA/lib/" && cp rust/solokey-core/src/frb_generated.rs "$SALIDA/src/"'
& (Join-Path $repo 'tool\build.ps1') -Salida $out -Comando $cmd
if ($LASTEXITCODE -ne 0) { Write-Host '[puente] FALLO' -ForegroundColor Red; exit $LASTEXITCODE }

$gen = Join-Path $repo 'lib\core\infrastructure\rust'
if (Test-Path -LiteralPath $gen) { Remove-Item -LiteralPath $gen -Recurse -Force }
Copy-Item -LiteralPath (Join-Path $out 'lib') -Destination $gen -Recurse
Copy-Item -LiteralPath (Join-Path $out 'src\frb_generated.rs') `
  -Destination (Join-Path $repo 'rust\solokey-core\src\frb_generated.rs') -Force
Remove-Item -LiteralPath $out -Recurse -Force
Write-Host '[puente] listo: lib/core/infrastructure/rust/ y src/frb_generated.rs' -ForegroundColor Green
