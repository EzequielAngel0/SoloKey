#requires -Version 5.1
<#
.SYNOPSIS
  Compila SoloKey y organiza los artefactos de release en la carpeta dist/.

.DESCRIPTION
  Genera y agrupa en dist/ (en la raiz del proyecto):
    - APK general (universal, todas las ABIs)         -> dist/SoloKey-<ver>-universal.apk
    - APKs split-per-abi (arm64-v8a / armeabi-v7a / x86_64)
                                                       -> dist/<abi>/SoloKey-<ver>-<abi>.apk
    - Build de Windows (.exe + DLLs + carpeta data)    -> dist/windows/

.PARAMETER Target
  Que compilar: android | windows | all. Por defecto: all.

.PARAMETER Clean
  Ejecuta 'flutter clean' antes de compilar.

.EXAMPLE
  ./build_release.ps1
  ./build_release.ps1 -Target android
  ./build_release.ps1 -Target windows -Clean
#>
[CmdletBinding()]
param(
    [ValidateSet('android', 'windows', 'all')]
    [string]$Target = 'all',
    [switch]$Clean
)

# NOTA: no usamos '$ErrorActionPreference = Stop' global porque en PowerShell 5.1
# cualquier linea que flutter escriba a stderr (p.ej. "Nuget.exe not found...")
# se convertiria en error terminante y abortaria el build. En su lugar validamos
# cada build con $LASTEXITCODE y usamos -ErrorAction Stop en las operaciones de archivo.

# Raiz del proyecto = carpeta donde vive este script.
$Root = $PSScriptRoot
Set-Location $Root

# ── Metadatos del proyecto (nombre fijo + version desde pubspec.yaml) ──────────
$AppName = 'SoloKey'
$pubspec = Get-Content (Join-Path $Root 'pubspec.yaml') -Raw
if ($pubspec -match '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)') {
    $Version = $Matches[1]
} else {
    $Version = '0.0.0'
}

$Dist = Join-Path $Root 'dist'

function Write-Step([string]$msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

function Confirm-Dir([string]$path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path -ErrorAction Stop | Out-Null
    }
}

# flutter en PATH?
if ($null -eq (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "No se encontro 'flutter' en el PATH. Instala el SDK de Flutter y agregalo al PATH."
}

if ($Clean) {
    Write-Step 'flutter clean'
    flutter clean
}

Write-Step 'flutter pub get'
flutter pub get

# ── Android ────────────────────────────────────────────────────────────────────
function Build-Android {
    $apkSrc = Join-Path $Root 'build\app\outputs\flutter-apk'

    # 1. APK universal (release). Se copia ANTES del split para no perderlo.
    Write-Step 'Compilando APK universal (release)'
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) { throw "Fallo 'flutter build apk --release' (exit $LASTEXITCODE)." }

    Confirm-Dir $Dist
    $universalSrc = Join-Path $apkSrc 'app-release.apk'
    if (Test-Path $universalSrc) {
        Copy-Item $universalSrc (Join-Path $Dist "$AppName-$Version-universal.apk") -Force -ErrorAction Stop
    } else {
        Write-Warning "No se encontro app-release.apk en $apkSrc"
    }

    # 2. APKs split-per-abi (release).
    Write-Step 'Compilando APKs split-per-abi (release)'
    flutter build apk --release --split-per-abi
    if ($LASTEXITCODE -ne 0) { throw "Fallo 'flutter build apk --split-per-abi' (exit $LASTEXITCODE)." }

    foreach ($abi in @('arm64-v8a', 'armeabi-v7a', 'x86_64')) {
        $src = Join-Path $apkSrc "app-$abi-release.apk"
        if (Test-Path $src) {
            $abiDir = Join-Path $Dist $abi
            Confirm-Dir $abiDir
            Copy-Item $src (Join-Path $abiDir "$AppName-$Version-$abi.apk") -Force -ErrorAction Stop
        } else {
            Write-Warning "No se encontro el APK para $abi"
        }
    }

    Write-Host "APKs listos en $Dist" -ForegroundColor Green
}

# ── Windows ────────────────────────────────────────────────────────────────────
function Build-Windows {
    Write-Step 'Compilando Windows (.exe, release)'
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw "Fallo 'flutter build windows --release' (exit $LASTEXITCODE)." }

    # La ruta de salida varia segun la version de Flutter.
    $candidates = @(
        (Join-Path $Root 'build\windows\x64\runner\Release'),
        (Join-Path $Root 'build\windows\runner\Release')
    )
    $winSrc = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($null -eq $winSrc) { throw 'No se encontro la carpeta Release de Windows.' }

    $winDest = Join-Path $Dist 'windows'
    if (Test-Path $winDest) { Remove-Item $winDest -Recurse -Force -ErrorAction Stop }
    Confirm-Dir $winDest
    Copy-Item (Join-Path $winSrc '*') $winDest -Recurse -Force -ErrorAction Stop

    Write-Host "Windows listo en $winDest (ejecutable + DLLs + data)" -ForegroundColor Green
}

# ── Ejecucion ───────────────────────────────────────────────────────────────────
Confirm-Dir $Dist

switch ($Target) {
    'android' { Build-Android }
    'windows' { Build-Windows }
    'all'     { Build-Android; Build-Windows }
}

Write-Step "Listo. Artefactos en: $Dist"
Get-ChildItem $Dist -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($Dist.Length + 1)
    $sizeMB = [Math]::Round($_.Length / 1MB, 2)
    Write-Host ("  {0,-52} {1,8} MB" -f $rel, $sizeMB)
}
