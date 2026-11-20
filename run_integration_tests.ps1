<#
.SYNOPSIS
  Corre la suite integration_test de SoloKey en Windows haciendo SIEMPRE un backup
  del vault real ANTES y restaurandolo DESPUES (pase lo que pase).

.DESCRIPTION
  El e2e destructivo (vault_e2e_test.dart) borra el vault REAL de Windows: la DB
  Drift en Documents (vault_guard_db.sqlite) y el secure storage DPAPI
  (flutter_secure_storage.dat). En una maquina con vault real esto borraria los
  datos del usuario, por eso esta gateado tras --dart-define=E2E_ALLOW_WIPE=1
  (ver docs/proceso/PRUEBAS_INTEGRACION.md).

  Desde NUC-6 (v2) todas las corridas van con datos AISLADOS
  (--dart-define=SOLOKEY_DATA_DIR=<carpeta temporal>, que un release ignora): la
  app y resetVault solo tocan esa carpeta, que se borra al final. El snapshot de la
  boveda real se queda como segunda red.

  Este script:
    1) Cierra cualquier SoloKey.exe abierto (libera el lock de instancia unica y
       los archivos de la DB).
    2) Toma un snapshot con hash de todo lo que el e2e puede tocar (la DB, el
       .dat de secure storage de cada identidad y la carpeta secure_files con los
       archivos seguros), en %USERPROFILE%. Si no puede leer la identidad de
       windows/runner/Runner.rc, no corre nada (ver tool/respaldo-boveda.psm1).
    3) Corre app_boot_test.dart (NO destructivo), migracion_v1_test.dart (migra la
       boveda de prueba de vectores/v1 dentro de la carpeta aislada) y, salvo
       -SkipDestructive, vault_e2e_test.dart dos veces (regla anti-flaky: dos
       verdes seguidas).
       En Windows se corre UN archivo por invocacion (instancia unica).
    4) En un bloque finally SIEMPRE restaura el snapshot (borra lo vivo, copia de
       vuelta lo que existia antes, verifica hash) y limpia los *.e2e-backup.
       Si algo no quedo igual, sale con 2 y deja el respaldo intacto.

  El respaldo se prueba sin tocar la boveda real con tool/probar-respaldo-boveda.ps1.

.PARAMETER SkipDestructive
  Corre solo app_boot_test.dart (no toca el vault). Seguro en cualquier equipo.

.PARAMETER KeepBackup
  No borra el directorio de backup al terminar (por defecto se conserva igual;
  este switch existe para dejarlo explicito).

.EXAMPLE
  .\run_integration_tests.ps1
  .\run_integration_tests.ps1 -SkipDestructive
#>
[CmdletBinding()]
param(
  [switch]$SkipDestructive,
  [switch]$KeepBackup
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$docs = [Environment]::GetFolderPath('MyDocuments')
$roaming = $env:APPDATA

# --- Targets: todo lo que un E2E puede tocar (DB, .dat de cada identidad y secure_files) ---
# La lista y el snapshot con hash viven en el modulo (probado por tool/probar-respaldo-boveda.ps1).
# Si no puede leer la identidad de Runner.rc, falla aqui, antes de tocar nada.
Import-Module (Join-Path $repo 'tool/respaldo-boveda.psm1') -Force
$targets = Get-VaultTargets -Repo $repo -Docs $docs -Roaming $roaming
$supportDirs = Get-SupportDirs -Repo $repo -Roaming $roaming

function Stop-SoloKey {
  Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessName -match 'SoloKey|password_manager' } |
    ForEach-Object { try { Stop-Process -Id $_.Id -Force } catch {} }
  Start-Sleep -Milliseconds 800
}

# --- 1) Cerrar la app y 2) tomar el snapshot -----------------------------------
Stop-SoloKey
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $env:USERPROFILE "SoloKey-e2e-backup-$stamp"
# Carpeta de datos aislada de las E2E (NUC-6); se borra al final.
$iso = Join-Path $env:TEMP "solokey-e2e-$stamp"
New-Item -ItemType Directory -Force -Path $backup | Out-Null

$manifest = New-VaultSnapshot -Targets $targets -BackupDir $backup
$manifest | ConvertTo-Json -Depth 6 | Out-File -Encoding utf8 (Join-Path $backup 'MANIFEST.json')
Write-Host "[backup] snapshot en $backup" -ForegroundColor Cyan
$manifest | Format-Table idx, kind, existedBefore, sha256, source -AutoSize

# --- 3) Correr los tests (UN archivo por invocacion en Windows) ----------------
$failed = $false
$restoreErrors = @('no se llego a restaurar')
try {
  Push-Location $repo
  Write-Host "[test] app_boot_test.dart (no destructivo)" -ForegroundColor Cyan
  & flutter test integration_test/app_boot_test.dart -d windows "--dart-define=SOLOKEY_DATA_DIR=$iso"
  if ($LASTEXITCODE -ne 0) { $failed = $true }

  Stop-SoloKey
  Write-Host "[test] migracion_v1_test.dart (solo la carpeta aislada)" -ForegroundColor Cyan
  & flutter test integration_test/migracion_v1_test.dart -d windows `
      --dart-define=E2E_ALLOW_WIPE=1 "--dart-define=SOLOKEY_DATA_DIR=$iso" `
      "--dart-define=SOLOKEY_V1_VECTORS=$(Join-Path $repo 'vectores\v1')"
  if ($LASTEXITCODE -ne 0) { $failed = $true }

  if (-not $SkipDestructive) {
    foreach ($run in 1, 2) {
      Stop-SoloKey
      Write-Host "[test] vault_e2e_test.dart (destructivo, corrida $run/2)" -ForegroundColor Cyan
      & flutter test integration_test/vault_e2e_test.dart -d windows `
          --dart-define=TEST_DISABLE_BIOMETRIC=1 --dart-define=E2E_ALLOW_WIPE=1 "--dart-define=SOLOKEY_DATA_DIR=$iso"
      if ($LASTEXITCODE -ne 0) { $failed = $true; break }
    }
  }
}
finally {
  Pop-Location
  if (Test-Path -LiteralPath $iso) { Remove-Item -LiteralPath $iso -Recurse -Force -ErrorAction SilentlyContinue }
  # --- 4) SIEMPRE restaurar --------------------------------------------------
  Stop-SoloKey
  Write-Host "[restore] devolviendo el vault al estado pre-corrida" -ForegroundColor Cyan
  $restoreErrors = Restore-VaultSnapshot -Manifest $manifest
  foreach ($m in $manifest) {
    $n = if ($m.kind -eq 'dir') { " ($(@($m.files).Count) archivos)" } else { '' }
    Write-Host ("  [{0}] {1} existia={2}{3}  {4}" -f $m.idx, $m.kind, $m.existedBefore, $n, $m.source)
  }
  foreach ($e in $restoreErrors) { Write-Warning "  NO RESTAURADO: $e" }
  # Limpia los *.e2e-backup que deja el helper resetVault (Documents y cada carpeta de soporte).
  foreach ($d in @($docs) + $supportDirs) {
    if (Test-Path -LiteralPath $d) {
      Get-ChildItem -LiteralPath $d -Filter '*.e2e-backup' -File -ErrorAction SilentlyContinue |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }
    }
  }
  if (-not $KeepBackup) { Write-Host "[backup] conservado en $backup (borralo tu si ya verificaste)" -ForegroundColor DarkGray }
}

if ($restoreErrors.Count -gt 0) {
  Write-Host "La boveda NO quedo igual que antes ($($restoreErrors.Count) diferencias). Respaldo intacto en $backup" -ForegroundColor Red
  exit 2
}
if ($failed) { Write-Host "Alguna corrida de integration_test fallo. Vault restaurado; revisa el log." -ForegroundColor Red; exit 1 }
Write-Host "OK: integration_test verde y vault restaurado (hashes verificados)." -ForegroundColor Green
