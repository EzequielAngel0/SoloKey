# Quita el worktree de una sesion SIN vaciar el cache de Pub.
#
# Flutter deja uniones (JUNCTION) en windows\flutter\ephemeral\.plugin_symlinks que apuntan al
# cache de Pub. En Windows, `git worktree remove` y `robocopy /MIR` (aun con /XJ) SIGUEN esas
# uniones y borran el contenido del cache de TODOS los proyectos. Aqui se quitan los enlaces primero y despues el worktree.
#
# Uso:  .\tool\quitar-worktree.ps1 ..\SoloKey-b
# Se niega si hay cambios sin commit o commits que no estan en origin/develop.
param([Parameter(Mandatory = $true)][string]$Ruta)
# 'Continue': en PowerShell 5.1 el stderr de un comando nativo ("File Not Found" de dir) con 'Stop' es fatal.
$ErrorActionPreference = 'Continue'

$ruta = (Resolve-Path -LiteralPath $Ruta -ErrorAction Stop).Path
$principal = (git rev-parse --show-toplevel) -replace '/', '\'
if ($ruta.TrimEnd('\') -ieq $principal.TrimEnd('\')) { Write-Host "[ERROR] esa es la carpeta principal, no un worktree"; exit 1 }

$cambios = @(git -C $ruta status --porcelain 2>$null)
if ($cambios.Count -gt 0) {
  Write-Host "[ERROR] $ruta tiene cambios sin commit:"
  $cambios | ForEach-Object { Write-Host "  $_" }
  exit 1
}
git fetch -q origin develop
$sinSubir = @(git -C $ruta log --oneline origin/develop..HEAD 2>$null)
if ($sinSubir.Count -gt 0) {
  Write-Host "[ERROR] $ruta tiene commits que no estan en origin/develop:"
  $sinSubir | ForEach-Object { Write-Host "  $_" }
  exit 1
}

# 1. Quitar los enlaces sin tocar su destino (rmdir de una union borra solo la union).
function Get-Enlaces($dir) { return @(cmd /c "dir /s /b /al `"$dir`" 2>nul") | Where-Object { $_ } }
foreach ($e in Get-Enlaces $ruta) {
  cmd /c "rmdir `"$e`" 2>nul"
  if (Test-Path -LiteralPath $e) { cmd /c "del /f /q `"$e`" 2>nul" }
}
$quedan = @(Get-Enlaces $ruta).Count
if ($quedan -gt 0) { Write-Host "[ERROR] quedan $quedan enlaces dentro de $ruta; no se borra, revisar a mano"; exit 1 }

# 2. Quitar el worktree (con rutas largas de Gradle, vaciar con robocopy: ya no hay enlaces que seguir).
git worktree remove --force $ruta 2>$null
if (Test-Path -LiteralPath $ruta) {
  $vacio = Join-Path $env:TEMP 'solokey-vacio'
  New-Item -ItemType Directory -Force $vacio | Out-Null
  robocopy $vacio $ruta /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
  Remove-Item -LiteralPath $ruta -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item $vacio -Force -ErrorAction SilentlyContinue
}
git worktree prune
if (Test-Path -LiteralPath $ruta) { Write-Host "[ERROR] no se pudo borrar (un daemon de Gradle o adb la retiene): $ruta"; exit 1 }
Write-Host "Worktree borrado: $ruta"
Write-Host "Falta borrar su rama: git branch -d <rama> ; git push origin --delete <rama>"
