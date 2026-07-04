<#
.SYNOPSIS
  Corre la suite integration_test de SoloKey en Windows haciendo SIEMPRE un backup
  del vault real ANTES y restaurandolo DESPUES (pase lo que pase).

.DESCRIPTION
  El e2e destructivo (vault_e2e_test.dart) borra el vault REAL de Windows: la DB
  Drift en Documents (vault_guard_db.sqlite) y el secure storage DPAPI
  (flutter_secure_storage.dat). En una maquina con vault real esto borraria los
  datos del usuario, por eso esta gateado tras --dart-define=E2E_ALLOW_WIPE=1
  (ver docs/prompts/PRUEBAS_INTEGRACION.md).

  Este script:
    1) Cierra cualquier SoloKey.exe abierto (libera el lock de instancia unica y
       los archivos de la DB).
    2) Toma un snapshot con hash de todo lo que el e2e puede tocar
       (DB + los .dat de secure storage conocidos), en %USERPROFILE%.
    3) Corre app_boot_test.dart (NO destructivo) y, salvo -SkipDestructive,
       vault_e2e_test.dart dos veces (regla anti-flaky: dos verdes seguidas).
       En Windows se corre UN archivo por invocacion (instancia unica).
    4) En un bloque finally SIEMPRE restaura el snapshot (borra lo vivo, copia de
       vuelta lo que existia antes, verifica hash) y limpia los *.e2e-backup.

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

# --- Targets: todo lo que resetVault (support/e2e_helpers.dart) puede tocar ------
# DB Drift (Documents, NO namespaced por identidad) + los .dat de secure storage
# de cada identidad conocida (%APPDATA%\<Company>\<Product>\...). Se agrega la
# identidad actual del runner por si cambia en el futuro.
$targets = [System.Collections.Generic.List[string]]::new()
$targets.Add((Join-Path $docs 'vault_guard_db.sqlite'))
$targets.Add((Join-Path $docs 'vault_guard_db.sqlite-wal'))
$targets.Add((Join-Path $docs 'vault_guard_db.sqlite-shm'))
$targets.Add((Join-Path $roaming 'com.vaultguard\password_manager\flutter_secure_storage.dat'))

# Identidad actual del runner (CompanyName\ProductName) -> su .dat.
$rc = Join-Path $repo 'windows\runner\Runner.rc'
if (Test-Path -LiteralPath $rc) {
  $rcText = Get-Content -LiteralPath $rc -Raw
  $company = ([regex]::Match($rcText, 'VALUE "CompanyName", "([^"]+?)\s*\\0"')).Groups[1].Value.Trim()
  $product = ([regex]::Match($rcText, 'VALUE "ProductName", "([^"]+?)\s*\\0"')).Groups[1].Value.Trim()
  if ($company -and $product) {
    $targets.Add((Join-Path $roaming (Join-Path $company (Join-Path $product 'flutter_secure_storage.dat'))))
  }
}
$targets = $targets | Select-Object -Unique

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
New-Item -ItemType Directory -Force -Path $backup | Out-Null

$manifest = @()
$idx = 0
foreach ($t in $targets) {
  $idx++
  $exists = Test-Path -LiteralPath $t
  $dest = ''; $hash = ''
  if ($exists) {
    $dest = Join-Path $backup ("{0:00}_{1}" -f $idx, (Split-Path $t -Leaf))
    Copy-Item -LiteralPath $t -Destination $dest -Force
    $hash = (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash
  }
  $manifest += [pscustomobject]@{ idx = $idx; source = $t; existedBefore = $exists; backupFile = $dest; sha256 = $hash }
}
$manifest | ConvertTo-Json -Depth 4 | Out-File -Encoding utf8 (Join-Path $backup 'MANIFEST.json')
Write-Host "[backup] snapshot en $backup" -ForegroundColor Cyan
$manifest | Format-Table idx, existedBefore, sha256, source -AutoSize

# --- 3) Correr los tests (UN archivo por invocacion en Windows) ----------------
$failed = $false
try {
  Push-Location $repo
  Write-Host "[test] app_boot_test.dart (no destructivo)" -ForegroundColor Cyan
  & flutter test integration_test/app_boot_test.dart -d windows
  if ($LASTEXITCODE -ne 0) { $failed = $true }

  if (-not $SkipDestructive) {
    foreach ($run in 1, 2) {
      Stop-SoloKey
      Write-Host "[test] vault_e2e_test.dart (destructivo, corrida $run/2)" -ForegroundColor Cyan
      & flutter test integration_test/vault_e2e_test.dart -d windows `
          --dart-define=TEST_DISABLE_BIOMETRIC=1 --dart-define=E2E_ALLOW_WIPE=1
      if ($LASTEXITCODE -ne 0) { $failed = $true; break }
    }
  }
}
finally {
  Pop-Location
  # --- 4) SIEMPRE restaurar --------------------------------------------------
  Stop-SoloKey
  Write-Host "[restore] devolviendo el vault al estado pre-corrida" -ForegroundColor Cyan
  foreach ($m in $manifest) {
    if (Test-Path -LiteralPath $m.source) { Remove-Item -LiteralPath $m.source -Force }
    if ($m.existedBefore) {
      $parent = Split-Path $m.source -Parent
      if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
      Copy-Item -LiteralPath $m.backupFile -Destination $m.source -Force
      $now = (Get-FileHash -LiteralPath $m.source -Algorithm SHA256).Hash
      $ok = ($now -eq $m.sha256)
      Write-Host ("  [{0}] restaurado match={1}  {2}" -f $m.idx, $ok, $m.source)
      if (-not $ok) { Write-Warning "  HASH NO COINCIDE en $($m.source) - revisa el backup $backup" }
    }
  }
  # Limpia los *.e2e-backup que deja el helper resetVault.
  foreach ($d in @($docs, (Join-Path $roaming 'com.vaultguard\password_manager'))) {
    if (Test-Path -LiteralPath $d) {
      Get-ChildItem -LiteralPath $d -Filter '*.e2e-backup' -File -ErrorAction SilentlyContinue |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }
    }
  }
  if (-not $KeepBackup) { Write-Host "[backup] conservado en $backup (borralo tu si ya verificaste)" -ForegroundColor DarkGray }
}

if ($failed) { Write-Error "Alguna corrida de integration_test fallo. Vault restaurado; revisa el log."; exit 1 }
Write-Host "OK: integration_test verde y vault restaurado (hashes verificados)." -ForegroundColor Green
