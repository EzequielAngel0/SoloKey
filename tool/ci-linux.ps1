<#
.SYNOPSIS
  Reproduce el CI de Linux (tests.yml) en Podman, con la misma version de Flutter.

.DESCRIPTION
  Rojo en CI y verde en local casi siempre es el sistema operativo: esto corre lo mismo
  que el job analyze-test-coverage de .github/workflows/tests.yml, pero en Podman.
    1) Lee flutter-version de tests.yml y, si falta, construye la imagen
       localhost/solokey-ci-linux:<version> (tool/ci-linux/Containerfile).
    2) Monta el repo en solo lectura y lo COPIA dentro del contenedor (sin build/ ni
       .dart_tool/): pub get escribe rutas de Linux y romperia el arbol de Windows.
    3) Corre los pasos del CI (pub get, analyze, test --coverage, gate de cobertura)
       o el -Comando que se le pase.
  El cache de Pub vive en el volumen solokey-pub-cache. Limpieza completa:
    podman rmi localhost/solokey-ci-linux:<version>; podman volume rm solokey-pub-cache
  Archivo en ASCII (PowerShell 5.1).

.PARAMETER Comando
  Comandos de bash a correr en /work tras pub get, en vez de los pasos del CI.

.PARAMETER Salida
  Carpeta del host que se monta con escritura en /out (para sacar archivos).

.PARAMETER Reconstruir
  Reconstruye la imagen aunque exista.

.EXAMPLE
  .\tool\ci-linux.ps1
  .\tool\ci-linux.ps1 -Comando 'flutter test test/core'
#>
[CmdletBinding()]
param(
  [string]$Comando = '',
  [string]$Salida = '',
  [switch]$Reconstruir
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$yml = Get-Content -LiteralPath (Join-Path $repo '.github\workflows\tests.yml') -Raw
$ver = ([regex]::Match($yml, "flutter-version:\s*'([^']+)'")).Groups[1].Value
if (-not $ver) { throw 'No se pudo leer flutter-version de .github/workflows/tests.yml' }
$image = "localhost/solokey-ci-linux:$ver"

& podman image exists $image
if ($Reconstruir -or $LASTEXITCODE -ne 0) {
  Write-Host "[ci-linux] construyendo $image" -ForegroundColor Cyan
  & podman build -t $image --build-arg "FLUTTER_VERSION=$ver" `
      -f (Join-Path $repo 'tool\ci-linux\Containerfile') (Join-Path $repo 'tool\ci-linux')
  if ($LASTEXITCODE -ne 0) { Write-Host 'FALLO la construccion de la imagen' -ForegroundColor Red; exit 1 }
}

if (-not $Comando) {
  # Los mismos pasos que tests.yml (job analyze-test-coverage).
  $Comando = 'flutter analyze && flutter test --coverage && dart run tool/check_coverage.dart "$(cat tool/coverage_min.txt)"'
}
$bash = @"
set -eo pipefail
mkdir -p /work
tar -C /src --exclude=./build --exclude=./.dart_tool --exclude=./coverage -cf - . | tar -C /work -xf -
cd /work
flutter pub get > /tmp/pub.log 2>&1 || { cat /tmp/pub.log; exit 1; }
$Comando
"@

# El script va en un archivo montado, no como argumento: PowerShell 5.1 rompe las comillas
# dobles al pasarlas a un ejecutable nativo. LF y UTF-8 sin BOM para bash.
$script = Join-Path ([IO.Path]::GetTempPath()) ("solokey-ci-linux-" + [guid]::NewGuid().ToString('N') + '.sh')
[IO.File]::WriteAllText($script, ($bash -replace "`r", ''), (New-Object Text.UTF8Encoding $false))

$runArgs = @('run', '--rm', '-v', "$(($repo -replace '\\', '/')):/src:ro", '-v', 'solokey-pub-cache:/pub-cache',
  '-v', "$(($script -replace '\\', '/')):/ci.sh:ro")
if ($Salida) {
  New-Item -ItemType Directory -Force -Path $Salida | Out-Null
  $runArgs += @('-v', "$(((Resolve-Path $Salida).Path -replace '\\', '/')):/out", '-e', 'SALIDA=/out')
}
$runArgs += @($image, 'bash', '/ci.sh')

Write-Host "[ci-linux] $image" -ForegroundColor Cyan
try { & podman @runArgs; $code = $LASTEXITCODE } finally { Remove-Item -LiteralPath $script -Force -ErrorAction SilentlyContinue }
if ($code -ne 0) { Write-Host "[ci-linux] ROJO (salida $code)" -ForegroundColor Red; exit $code }
Write-Host '[ci-linux] VERDE' -ForegroundColor Green
