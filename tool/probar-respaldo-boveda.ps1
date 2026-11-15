<#
.SYNOPSIS
  Prueba tool\respaldo-boveda.psm1 sobre una boveda FALSA en una carpeta temporal (nunca la real).

.DESCRIPTION
  Arma un arbol con la forma del de Windows (Documents + %APPDATA%\<Company>\<Product> con la
  identidad de windows\runner\Runner.rc + la identidad vieja), toma el snapshot, simula lo que
  hace un E2E (borra la BD, cambia el .dat, WipeVaultUseCase borra secure_files\ y la prueba crea
  archivos nuevos), restaura y exige que todo quede igual que antes, con hash.
  Sale con 0 si todo pasa y 1 si algo falla. Archivo en ASCII (PowerShell 5.1).

.EXAMPLE
  .\tool\probar-respaldo-boveda.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Import-Module (Join-Path $repo 'tool\respaldo-boveda.psm1') -Force

$fails = 0
function Check([string]$name, [bool]$ok, [string]$detail = '') {
  if ($ok) { Write-Host "  PASA  $name" -ForegroundColor Green }
  else { Write-Host "  FALLA $name $detail" -ForegroundColor Red; $script:fails++ }
}
function Put([string]$path, [string]$text) {
  New-Item -ItemType Directory -Force -Path (Split-Path $path -Parent) | Out-Null
  [IO.File]::WriteAllText($path, $text)
}

$root = Join-Path $env:TEMP ('solokey-prueba-respaldo-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
$docs = Join-Path $root 'Documents'
$roaming = Join-Path $root 'Roaming'
$backup = Join-Path $root 'backup'
try {
  # --- La identidad sale de Runner.rc y, si no se puede leer, falla cerrado ---
  $identity = Get-RunnerIdentity -Repo $repo
  Check 'lee la identidad de Runner.rc' ($identity -like '*\*') "($identity)"
  $badRepo = Join-Path $root 'repo-sin-identidad'
  Put (Join-Path $badRepo 'windows\runner\Runner.rc') 'BEGIN END'
  $threw = $false
  try { Get-VaultTargets -Repo $badRepo -Docs $docs -Roaming $roaming | Out-Null } catch { $threw = $true }
  Check 'sin identidad legible no sigue' $threw

  # --- Boveda falsa ---
  $current = Join-Path $roaming $identity
  $legacy = Join-Path $roaming 'com.vaultguard\password_manager'
  Put (Join-Path $docs 'vault_guard_db.sqlite') 'db-original'
  Put (Join-Path $docs 'vault_guard_db.sqlite-wal') 'wal-original'
  # -shm NO existe antes: si la prueba lo crea, la restauracion lo tiene que quitar.
  Put (Join-Path $current 'flutter_secure_storage.dat') 'clave-envuelta-actual'
  Put (Join-Path $legacy 'flutter_secure_storage.dat') 'clave-envuelta-vieja'
  Put (Join-Path $current 'secure_files\a1.enc') 'archivo-seguro-1'
  Put (Join-Path $current 'secure_files\b2.enc') 'archivo-seguro-2'
  Put (Join-Path $current 'secure_files\sub\c3.enc') 'archivo-seguro-3'
  $pristine = @{}
  Get-ChildItem -LiteralPath $root -Recurse -File | ForEach-Object {
    $pristine[$_.FullName] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
  }

  # --- Snapshot ---
  $targets = Get-VaultTargets -Repo $repo -Docs $docs -Roaming $roaming
  $manifest = New-VaultSnapshot -Targets $targets -BackupDir $backup
  Check 'el snapshot recien tomado coincide con lo vivo' ((Test-VaultMatchesSnapshot -Manifest $manifest).Count -eq 0)

  # --- Lo que hace un E2E ---
  Remove-Item -LiteralPath (Join-Path $docs 'vault_guard_db.sqlite') -Force
  Put (Join-Path $docs 'vault_guard_db.sqlite') 'db-de-la-prueba'
  Put (Join-Path $docs 'vault_guard_db.sqlite-shm') 'shm-de-la-prueba'
  Put (Join-Path $current 'flutter_secure_storage.dat') 'clave-de-la-prueba'
  Remove-Item -LiteralPath (Join-Path $current 'secure_files') -Recurse -Force
  Put (Join-Path $current 'secure_files\nuevo.enc') 'archivo-de-la-prueba'
  Check 'la simulacion cambio la boveda' ((Test-VaultMatchesSnapshot -Manifest $manifest).Count -gt 0)

  # --- Restaurar ---
  $left = Restore-VaultSnapshot -Manifest $manifest
  Check 'la restauracion no reporta diferencias' ($left.Count -eq 0) ($left -join '; ')
  foreach ($f in $pristine.Keys) {
    if ($f.StartsWith($backup) -or $f -like "*repo-sin-identidad*") { continue }
    $ok = (Test-Path -LiteralPath $f) -and ((Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash -eq $pristine[$f])
    Check ("vuelve igual: " + ($f -replace "^.*?solokey-prueba-respaldo-[^\\]+\\", "")) $ok
  }
  Check 'quita lo que la prueba creo (-shm)' (-not (Test-Path -LiteralPath (Join-Path $docs 'vault_guard_db.sqlite-shm')))
  Check 'quita lo que la prueba creo (secure_files\nuevo.enc)' (-not (Test-Path -LiteralPath (Join-Path $current 'secure_files\nuevo.enc')))

  # --- La verificacion detecta un archivo seguro cambiado ---
  Put (Join-Path $current 'secure_files\a1.enc') 'alterado'
  Check 'detecta un archivo seguro alterado' ((Test-VaultMatchesSnapshot -Manifest $manifest).Count -gt 0)
}
finally {
  if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
}

if ($fails -gt 0) { Write-Host "$fails comprobacion(es) fallaron" -ForegroundColor Red; exit 1 }
Write-Host 'OK: respaldo y restauracion de la boveda verificados' -ForegroundColor Green
exit 0
