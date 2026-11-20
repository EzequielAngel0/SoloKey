<#
.SYNOPSIS
  Fuzz del nucleo Rust (SEG-2) con cargo-fuzz, dentro de Podman.

.DESCRIPTION
  Corre cada objetivo de rust/solokey-core/fuzz/fuzz_targets durante -Segundos. Rust nightly y cargo-fuzz
  van en la imagen localhost/solokey-fuzz:<nightly> (rust/solokey-core/fuzz/Containerfile); nada va al host.
  El corpus que crece vive en el volumen solokey-fuzz-corpus; las semillas fijas, en fuzz/semillas.
  Un fallo deja su entrada en rust/solokey-core/fuzz/artifacts/<objetivo>/ para reproducirlo:
    .\rust\fuzz.ps1 -Objetivo <objetivo> -Reproducir artifacts/<objetivo>/<archivo>
  Limpieza: podman rmi localhost/solokey-fuzz:<nightly>
            podman volume rm solokey-fuzz-corpus solokey-fuzz-target
  Archivo en ASCII (PowerShell 5.1).

.EXAMPLE
  .\rust\fuzz.ps1
  .\rust\fuzz.ps1 -Objetivo sync_mensaje -Segundos 600
#>
[CmdletBinding()]
param(
  [string]$Objetivo = '',
  [int]$Segundos = 60,
  [string]$Reproducir = '',
  [switch]$Reconstruir
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$fuzz = Join-Path $repo 'rust\solokey-core\fuzz'
$cf = Get-Content -LiteralPath (Join-Path $fuzz 'Containerfile') -Raw
$nightly = ([regex]::Match($cf, 'ARG NIGHTLY=(\S+)')).Groups[1].Value
if (-not $nightly) { throw 'No se pudo leer ARG NIGHTLY del Containerfile' }
$image = "localhost/solokey-fuzz:$nightly"

& podman image exists $image
if ($Reconstruir -or $LASTEXITCODE -ne 0) {
  Write-Host "[fuzz] construyendo $image" -ForegroundColor Cyan
  & podman build -t $image -f (Join-Path $fuzz 'Containerfile') $fuzz
  if ($LASTEXITCODE -ne 0) { Write-Host 'FALLO la construccion de la imagen' -ForegroundColor Red; exit 1 }
}

$objetivos = @(Get-ChildItem -LiteralPath (Join-Path $fuzz 'fuzz_targets') -Filter '*.rs' | ForEach-Object { $_.BaseName })
if ($Objetivo) {
  if ($objetivos -notcontains $Objetivo) { throw "Objetivo desconocido: $Objetivo (hay: $($objetivos -join ', '))" }
  $objetivos = @($Objetivo)
}

# El script va en un archivo montado: PowerShell 5.1 rompe las comillas de los argumentos nativos.
$lineas = @('set -euo pipefail', 'cd /repo/rust/solokey-core/fuzz', 'fallos=0')
foreach ($t in $objetivos) {
  if ($Reproducir) {
    $lineas += "cargo fuzz run $t '$Reproducir' || fallos=1"
  } else {
    # Plantilla en comillas simples: PowerShell no toca los $ de bash; solo se cambian OBJ y SEG.
    $plantilla = @'
echo "[fuzz] OBJ (SEG s)"
mkdir -p /corpus/OBJ
if cargo fuzz run OBJ /corpus/OBJ semillas/OBJ -- -max_total_time=SEG -rss_limit_mb=2048 -timeout=10 -print_final_stats=1 > /tmp/OBJ.log 2>&1; then
  grep -E '^(stat::number_of_executed_units|stat::peak_rss_mb)' /tmp/OBJ.log || true
else
  echo "[fuzz] FALLO en OBJ"; tail -n 60 /tmp/OBJ.log; fallos=1
fi
'@
    $lineas += ($plantilla -creplace 'OBJ', $t -creplace 'SEG', "$Segundos")
  }
}
$lineas += 'exit $fallos'
$script = Join-Path ([IO.Path]::GetTempPath()) ('solokey-fuzz-' + [guid]::NewGuid().ToString('N') + '.sh')
[IO.File]::WriteAllText($script, ((($lineas -join "`n") + "`n") -replace "`r", ''), (New-Object Text.UTF8Encoding $false))

$runArgs = @('run', '--rm',
  '-v', "$(($repo -replace '\\', '/')):/repo",
  '-v', 'solokey-cargo-registry:/usr/local/cargo/registry',
  '-v', 'solokey-fuzz-target:/repo/rust/solokey-core/fuzz/target',
  '-v', 'solokey-fuzz-corpus:/corpus',
  '-v', "$(($script -replace '\\', '/')):/fuzz.sh:ro",
  $image, 'bash', '/fuzz.sh')
try { & podman @runArgs; $code = $LASTEXITCODE } finally { Remove-Item -LiteralPath $script -Force -ErrorAction SilentlyContinue }
if ($code -ne 0) { Write-Host "[fuzz] ROJO (salida $code): mira rust/solokey-core/fuzz/artifacts" -ForegroundColor Red; exit $code }
Write-Host '[fuzz] VERDE: ningun fallo' -ForegroundColor Green
