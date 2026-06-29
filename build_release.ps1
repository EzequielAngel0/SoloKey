#requires -Version 5.1
<#
.SYNOPSIS
  Compila SoloKey (Android + Windows) y arma los artefactos de release en dist/.

.DESCRIPTION
  Genera y agrupa en dist/ (raiz del proyecto):
    - APK universal (todas las ABIs)   -> dist/SoloKey-<ver>-universal.apk
    - APKs split-per-abi               -> dist/<abi>/SoloKey-<ver>-<abi>.apk
    - App Bundle (.aab, opcional)      -> dist/SoloKey-<ver>.aab            (-Aab; Play Store)
    - Portable de Windows (.zip)       -> dist/SoloKey-<ver>-windows-portable.zip
    - Instalador de Windows            -> dist/SoloKey-<ver>-setup.exe       (Inno Setup, requiere ISCC.exe)
    - SHA256SUMS.txt                   -> checksums de todos los artefactos
    - build-<ver>.log                  -> transcript completo (para depurar si algo falla)

.PARAMETER Target
  Que compilar: android | windows | inno | all. Por defecto: all (android + inno).
    android -> solo APKs (+ aab si -Aab)
    windows -> solo el .exe + portable .zip
    inno    -> windows + instalador .exe
    all     -> android + inno

.PARAMETER Clean       Ejecuta 'flutter clean' antes de compilar.
.PARAMETER Aab         Tambien genera el App Bundle (.aab) de Android.
.PARAMETER Obfuscate   Compila con --obfuscate --split-debug-info (recomendado para release).
.PARAMETER SkipPubGet  Salta 'flutter pub get'.
.PARAMETER Version     Sobrescribe la version (por defecto, la de pubspec.yaml).

.EXAMPLE
  ./build_release.ps1
  ./build_release.ps1 -Target android -Aab -Obfuscate
  ./build_release.ps1 -Target inno -Clean

.NOTES
  Si Windows bloquea el script:  powershell -ExecutionPolicy Bypass -File .\build_release.ps1
#>
[CmdletBinding()]
param(
    [ValidateSet('android', 'windows', 'inno', 'all')]
    [string]$Target = 'all',
    [switch]$Clean,
    [switch]$Aab,
    [switch]$Obfuscate,
    [switch]$SkipPubGet,
    [string]$Version
)

# NOTA: no usamos '$ErrorActionPreference = Stop' global porque en PowerShell 5.1
# cualquier linea que flutter escriba a stderr (p.ej. "Nuget.exe not found...") se
# convertiria en error terminante y abortaria el build. En su lugar validamos cada
# paso con $LASTEXITCODE y usamos -ErrorAction Stop en las operaciones de archivo.

$Root = $PSScriptRoot
Set-Location $Root

# ── Metadatos (nombre fijo + version desde pubspec.yaml, salvo -Version) ──────────
$AppName = 'SoloKey'
if (-not $Version) {
    $pubspec = Get-Content (Join-Path $Root 'pubspec.yaml') -Raw
    if ($pubspec -match '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)') {
        $Version = $Matches[1]
    } else {
        $Version = '0.0.0'
    }
}

$Dist = Join-Path $Root 'dist'
$DebugSymbols = Join-Path $Dist 'debug-symbols'

function Write-Step([string]$msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

function Confirm-Dir([string]$path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path -ErrorAction Stop | Out-Null
    }
}

# Corre flutter con los args dados y aborta con mensaje claro si exit != 0.
function Invoke-Flutter([string[]]$FlutterArgs, [string]$What) {
    Write-Step $What
    & flutter @FlutterArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo: 'flutter $($FlutterArgs -join ' ')' (exit $LASTEXITCODE). Revisa el log dist\build-$Version.log; para mas detalle reejecuta con --verbose."
    }
}

# Flags comunes de release (ofuscacion opcional). Va a un array splatteable.
function Get-ReleaseFlags() {
    $flags = @()
    if ($Obfuscate) { $flags += @('--obfuscate', "--split-debug-info=$DebugSymbols") }
    return , $flags
}

# ── Localizadores (Windows Release + ISCC) ───────────────────────────────────────
function Find-WindowsRelease {
    $candidates = @(
        (Join-Path $Root 'build\windows\x64\runner\Release'),
        (Join-Path $Root 'build\windows\runner\Release')
    )
    $winSrc = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($null -eq $winSrc) { throw 'No se encontro la carpeta Release de Windows (build\windows\...\runner\Release).' }
    return $winSrc
}

function Find-Iscc {
    $candidates = @(
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 5\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe"
    )
    $found = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($null -eq $found) {
        $cmd = Get-Command iscc -ErrorAction SilentlyContinue
        if ($cmd) { $found = $cmd.Source }
    }
    if ($null -eq $found) {
        throw "No se encontro ISCC.exe (Inno Setup). Instalalo con:  winget install JRSoftware.InnoSetup   (o https://jrsoftware.org/isdl.php)"
    }
    return $found
}

# ── Android ──────────────────────────────────────────────────────────────────────
function Build-Android {
    $apkSrc = Join-Path $Root 'build\app\outputs\flutter-apk'
    $flags = Get-ReleaseFlags

    # 1. APK universal (release). Se copia ANTES del split para no perderlo.
    Invoke-Flutter (@('build', 'apk', '--release') + $flags) 'Compilando APK universal (release)'
    Confirm-Dir $Dist
    $universalSrc = Join-Path $apkSrc 'app-release.apk'
    if (Test-Path $universalSrc) {
        Copy-Item $universalSrc (Join-Path $Dist "$AppName-$Version-universal.apk") -Force -ErrorAction Stop
    } else {
        Write-Warning "No se encontro app-release.apk en $apkSrc"
    }

    # 2. APKs split-per-abi (release).
    Invoke-Flutter (@('build', 'apk', '--release', '--split-per-abi') + $flags) 'Compilando APKs split-per-abi (release)'
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

    # 3. App Bundle (opcional, para Play Store).
    if ($Aab) {
        Invoke-Flutter (@('build', 'appbundle', '--release') + $flags) 'Compilando App Bundle (.aab)'
        $aabSrc = Join-Path $Root 'build\app\outputs\bundle\release\app-release.aab'
        if (Test-Path $aabSrc) {
            Copy-Item $aabSrc (Join-Path $Dist "$AppName-$Version.aab") -Force -ErrorAction Stop
        } else {
            Write-Warning "No se encontro app-release.aab"
        }
    }

    Write-Host "APKs listos en $Dist" -ForegroundColor Green
}

# ── Windows (.exe portable) ──────────────────────────────────────────────────────
function Build-Windows {
    $flags = Get-ReleaseFlags
    Invoke-Flutter (@('build', 'windows', '--release') + $flags) 'Compilando Windows (.exe, release)'
    $relDir = Find-WindowsRelease

    # Portable: zip de toda la carpeta Release (exe + DLLs + data).
    Confirm-Dir $Dist
    $zip = Join-Path $Dist "$AppName-$Version-windows-portable.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force -ErrorAction Stop }
    Write-Step 'Empaquetando portable de Windows (.zip)'
    Compress-Archive -Path (Join-Path $relDir '*') -DestinationPath $zip -Force
    Write-Host "Portable -> $zip" -ForegroundColor Green
    return $relDir
}

# ── Instalador Inno Setup (Windows) ──────────────────────────────────────────────
function Build-Inno {
    # No capturar el retorno de Build-Windows: filtra el stdout de 'flutter build'
    # al valor de retorno y contaminaria /DSourceDir. Resolvemos la ruta aparte.
    Build-Windows
    $relDir = Find-WindowsRelease
    if (-not $script:Iscc) { $script:Iscc = Find-Iscc }
    Write-Step 'Generando instalador con Inno Setup (SoloKey-setup.exe)'
    & $script:Iscc "/DMyAppVersion=$Version" "/DSourceDir=$relDir" (Join-Path $Root 'installer\SoloKey.iss')
    if ($LASTEXITCODE -ne 0) { throw "Fallo ISCC / Inno Setup (exit $LASTEXITCODE)." }
    Write-Host "Instalador -> $(Join-Path $Dist "$AppName-$Version-setup.exe")" -ForegroundColor Green
}

# ── Checksums ────────────────────────────────────────────────────────────────────
function Write-Checksums {
    $files = Get-ChildItem $Dist -Recurse -File |
        Where-Object { $_.Name -ne 'SHA256SUMS.txt' -and $_.Extension -ne '.log' }
    if (-not $files) { return }
    $lines = foreach ($f in $files) {
        $hash = (Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLower()
        $rel = $f.FullName.Substring($Dist.Length + 1)
        "$hash  $rel"
    }
    Set-Content -Path (Join-Path $Dist 'SHA256SUMS.txt') -Value $lines -Encoding ascii
}

# ── Pre-flight (falla rapido ANTES de builds largos) ─────────────────────────────
if ($null -eq (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "No se encontro 'flutter' en el PATH. Instala el SDK de Flutter y agregalo al PATH."
}
$script:Iscc = $null
if ($Target -eq 'inno' -or $Target -eq 'all') {
    # Validar ISCC ahora para no descubrir que falta tras 10 min de build.
    $script:Iscc = Find-Iscc
    Write-Host "Inno Setup OK: $script:Iscc" -ForegroundColor DarkGray
}

# ── Ejecucion ───────────────────────────────────────────────────────────────────
# dist/ fresco para no mezclar artefactos viejos, y transcript para depurar.
Confirm-Dir $Dist
Get-ChildItem $Dist -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Confirm-Dir $Dist
Start-Transcript -Path (Join-Path $Dist "build-$Version.log") | Out-Null

try {
    Write-Host "SoloKey $Version  |  Target: $Target  |  Obfuscate: $Obfuscate  |  Aab: $Aab" -ForegroundColor Yellow

    if ($Clean) { Invoke-Flutter @('clean') 'flutter clean' }
    if (-not $SkipPubGet) { Invoke-Flutter @('pub', 'get') 'flutter pub get' }

    switch ($Target) {
        'android' { Build-Android }
        'windows' { [void] (Build-Windows) }
        'inno'    { Build-Inno }
        'all'     { Build-Android; Build-Inno }
    }

    Write-Checksums

    Write-Step "Listo. Artefactos en: $Dist"
    Get-ChildItem $Dist -Recurse -File | Where-Object { $_.Extension -ne '.log' } | ForEach-Object {
        $rel = $_.FullName.Substring($Dist.Length + 1)
        $sizeMB = [Math]::Round($_.Length / 1MB, 2)
        Write-Host ("  {0,-52} {1,8} MB" -f $rel, $sizeMB)
    }
} finally {
    Stop-Transcript | Out-Null
}
