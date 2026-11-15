# Respaldo y restauracion de la boveda de Windows para las pruebas E2E.
# Lo usa run_integration_tests.ps1; lo prueba tool\probar-respaldo-boveda.ps1.
# Archivo en ASCII (PowerShell 5.1).
#
# Que se respalda (todo lo que un E2E puede tocar en Windows):
#   - Documents\vault_guard_db.sqlite (+ -wal, -shm): la BD de drift.
#   - %APPDATA%\<Company>\<Product>\flutter_secure_storage.dat: identidad actual (Runner.rc).
#   - %APPDATA%\<Company>\<Product>\secure_files\: los archivos seguros (*.enc), carpeta entera.
#   - Lo mismo bajo la identidad vieja com.vaultguard\password_manager.
# Si no se puede leer la identidad de Runner.rc, falla: sin ella no se sabe que respaldar.

Set-StrictMode -Version 2

$script:LegacyIdentity = 'com.vaultguard\password_manager'

function Get-RunnerIdentity {
  param([Parameter(Mandatory)][string]$Repo)
  $rc = Join-Path $Repo 'windows\runner\Runner.rc'
  if (-not (Test-Path -LiteralPath $rc)) { throw "No existe $rc" }
  $text = Get-Content -LiteralPath $rc -Raw
  # Formato real: VALUE "CompanyName", "Angel Ezequiel Barbosa Lomeli" "\0"
  $company = ([regex]::Match($text, 'VALUE "CompanyName",\s*"([^"]+)"')).Groups[1].Value.Trim()
  $product = ([regex]::Match($text, 'VALUE "ProductName",\s*"([^"]+)"')).Groups[1].Value.Trim()
  if (-not $company -or -not $product) {
    throw "No se pudo leer CompanyName/ProductName de $rc; no se sabe que respaldar"
  }
  return Join-Path $company $product
}

# Carpetas de soporte (getApplicationSupportDirectory) de cada identidad conocida.
function Get-SupportDirs {
  param(
    [Parameter(Mandatory)][string]$Repo,
    [Parameter(Mandatory)][string]$Roaming
  )
  $ids = @((Get-RunnerIdentity -Repo $Repo), $script:LegacyIdentity) | Select-Object -Unique
  return @($ids | ForEach-Object { Join-Path $Roaming $_ })
}

function Get-VaultTargets {
  param(
    [Parameter(Mandatory)][string]$Repo,
    [Parameter(Mandatory)][string]$Docs,
    [Parameter(Mandatory)][string]$Roaming
  )
  $files = New-Object System.Collections.Generic.List[string]
  $dirs = New-Object System.Collections.Generic.List[string]
  foreach ($ext in 'sqlite', 'sqlite-wal', 'sqlite-shm') {
    $files.Add((Join-Path $Docs "vault_guard_db.$ext"))
  }
  foreach ($support in (Get-SupportDirs -Repo $Repo -Roaming $Roaming)) {
    $files.Add((Join-Path $support 'flutter_secure_storage.dat'))
    $dirs.Add((Join-Path $support 'secure_files'))
  }
  return [pscustomobject]@{
    Files = @($files | Select-Object -Unique)
    Dirs  = @($dirs | Select-Object -Unique)
  }
}

function Get-DirHashes {
  param([Parameter(Mandatory)][string]$Dir)
  $root = (Get-Item -LiteralPath $Dir).FullName.TrimEnd('\')
  $out = @()
  Get-ChildItem -LiteralPath $root -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
    $out += [pscustomobject]@{
      rel    = $_.FullName.Substring($root.Length).TrimStart('\')
      sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
  }
  return , $out
}

# Copia cada objetivo a $BackupDir y devuelve el manifiesto (con hashes).
function New-VaultSnapshot {
  param(
    [Parameter(Mandatory)]$Targets,
    [Parameter(Mandatory)][string]$BackupDir
  )
  New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
  $manifest = @()
  $idx = 0
  foreach ($t in $Targets.Files) {
    $idx++
    $exists = Test-Path -LiteralPath $t -PathType Leaf
    $dest = ''; $hash = ''
    if ($exists) {
      $dest = Join-Path $BackupDir ('{0:00}_{1}' -f $idx, (Split-Path $t -Leaf))
      Copy-Item -LiteralPath $t -Destination $dest -Force
      $hash = (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash
      if ($hash -ne (Get-FileHash -LiteralPath $t -Algorithm SHA256).Hash) {
        throw "La copia de $t no coincide con el original"
      }
    }
    $manifest += [pscustomobject]@{
      idx = $idx; kind = 'file'; source = $t; existedBefore = $exists
      backup = $dest; sha256 = $hash; files = @()
    }
  }
  foreach ($d in $Targets.Dirs) {
    $idx++
    $exists = Test-Path -LiteralPath $d -PathType Container
    $dest = ''; $files = @()
    if ($exists) {
      $dest = Join-Path $BackupDir ('{0:00}_{1}' -f $idx, (Split-Path $d -Leaf))
      Copy-Item -LiteralPath $d -Destination $dest -Recurse -Force
      $files = Get-DirHashes -Dir $d
      $copied = Get-DirHashes -Dir $dest
      if (($files | ConvertTo-Json -Compress) -ne ($copied | ConvertTo-Json -Compress)) {
        throw "La copia de la carpeta $d no coincide con el original"
      }
    }
    $manifest += [pscustomobject]@{
      idx = $idx; kind = 'dir'; source = $d; existedBefore = $exists
      backup = $dest; sha256 = ''; files = $files
    }
  }
  return , $manifest
}

# Compara lo vivo con el manifiesto. Devuelve la lista de diferencias (vacia = igual).
function Test-VaultMatchesSnapshot {
  param([Parameter(Mandatory)]$Manifest)
  $errors = @()
  foreach ($m in $Manifest) {
    if ($m.kind -eq 'file') {
      $exists = Test-Path -LiteralPath $m.source -PathType Leaf
      if ($exists -ne $m.existedBefore) {
        $errors += "existe=$exists (antes $($m.existedBefore)): $($m.source)"
      } elseif ($exists) {
        $now = (Get-FileHash -LiteralPath $m.source -Algorithm SHA256).Hash
        if ($now -ne $m.sha256) { $errors += "hash distinto: $($m.source)" }
      }
    } else {
      $exists = Test-Path -LiteralPath $m.source -PathType Container
      if ($exists -ne $m.existedBefore) {
        $errors += "existe=$exists (antes $($m.existedBefore)): $($m.source)\"
      } elseif ($exists) {
        $want = @($m.files | ForEach-Object { "$($_.rel)=$($_.sha256)" })
        $have = @((Get-DirHashes -Dir $m.source) | ForEach-Object { "$($_.rel)=$($_.sha256)" })
        $diff = Compare-Object -ReferenceObject $want -DifferenceObject $have
        foreach ($x in @($diff)) {
          if ($null -eq $x) { continue }
          $what = if ($x.SideIndicator -eq '<=') { 'falta o cambio' } else { 'sobra o cambio' }
          $errors += "$what en $($m.source): $($x.InputObject.Split('=')[0])"
        }
      }
    }
  }
  return , $errors
}

# Devuelve lo vivo al estado del manifiesto y lo verifica con hash.
# Devuelve la lista de diferencias que queden (vacia = restaurado).
function Restore-VaultSnapshot {
  param([Parameter(Mandatory)]$Manifest)
  foreach ($m in $Manifest) {
    if (Test-Path -LiteralPath $m.source) {
      Remove-Item -LiteralPath $m.source -Recurse -Force
    }
    if ($m.existedBefore) {
      $parent = Split-Path $m.source -Parent
      if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
      if ($m.kind -eq 'file') {
        Copy-Item -LiteralPath $m.backup -Destination $m.source -Force
      } else {
        Copy-Item -LiteralPath $m.backup -Destination $m.source -Recurse -Force
      }
    }
  }
  return Test-VaultMatchesSnapshot -Manifest $Manifest
}

Export-ModuleMember -Function Get-RunnerIdentity, Get-SupportDirs, Get-VaultTargets, New-VaultSnapshot, `
  Test-VaultMatchesSnapshot, Restore-VaultSnapshot
