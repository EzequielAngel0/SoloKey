<#
.SYNOPSIS
  Escaneo diario de dependencias de SoloKey (PLA-6). Solo lectura.

.DESCRIPTION
  1) OSV-Scanner en Podman (imagen fijada por version y digest) sobre pubspec.lock y
     rust/Cargo.lock, con el repo montado de solo lectura. Hallazgo = severidad alta o
     critica (CVSS >= 7.0) CON version que lo arregla; lo demas es aviso.
  2) flutter pub outdated --json: cuenta lo que tiene version nueva compatible, los
     mayores pendientes (alimentan PLA-4 y PLA-10) y los paquetes descontinuados.
  3) Alertas abiertas de Dependabot en GitHub (gh api). Si estan apagadas es un aviso
     (se encienden con PLA-7).
  Guarda el resultado del dia en .claude\estado\escaneo-deps.json (local, ignorado) y,
  si ya hay uno de hoy, lo repite sin volver a medir salvo con -Forzar.
  Salida: 0 = limpio, 2 = hay algo que contarle al dueno, 1 = error.
  Sin rastro en el host: el contenedor se borra al salir (--rm). Para borrar la imagen:
    podman rmi ghcr.io/google/osv-scanner:v2.7.0
  Archivo en ASCII (PowerShell 5.1).

.PARAMETER Forzar
  Vuelve a medir aunque ya exista el resultado de hoy.

.PARAMETER Umbral
  CVSS desde el que una vulnerabilidad con arreglo es hallazgo (7.0). Bajarlo sirve para
  ver el gate en 2 con un aviso real.

.PARAMETER Imagen
  Imagen de OSV-Scanner (fijada por version y digest). Cambiarla solo para probar el error.

.EXAMPLE
  .\tool\escaneo-deps.ps1
  .\tool\escaneo-deps.ps1 -Forzar
#>
param(
  [switch]$Forzar,
  [double]$Umbral = 7.0,
  [string]$Imagen = 'ghcr.io/google/osv-scanner:v2.7.0@sha256:4f3b7e2c64b9d38a5febc5a7e4a3dfef1d1362f726dea7a2ef4762b46469fcd0'
)

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$raiz = Split-Path -Parent $PSScriptRoot
$estadoDir = Join-Path $raiz '.claude\estado'
$estadoArchivo = Join-Path $estadoDir 'escaneo-deps.json'
$hoy = (Get-Date).ToString('yyyy-MM-dd')

function Escribir-Resumen($r) {
  Write-Host "Escaneo de dependencias del $($r.fecha)"
  Write-Host ("  OSV:        {0} paquetes, {1} hallazgos, {2} avisos" -f $r.osv.paquetes, @($r.osv.hallazgos).Count, @($r.osv.avisos).Count)
  foreach ($h in @($r.osv.hallazgos)) { Write-Host "    HALLAZGO $h" }
  foreach ($a in @($r.osv.avisos)) { Write-Host "    aviso    $a" }
  Write-Host ("  pub:        {0} con version compatible, {1} mayores pendientes, {2} descontinuados" -f @($r.pub.compatibles).Count, @($r.pub.mayores).Count, @($r.pub.descontinuados).Count)
  foreach ($d in @($r.pub.descontinuados)) { Write-Host "    DESCONTINUADO $d" }
  Write-Host "  Dependabot: $($r.dependabot.estado), $(@($r.dependabot.abiertas).Count) alertas abiertas"
  foreach ($a in @($r.dependabot.abiertas)) { Write-Host "    ALERTA $a" }
  foreach ($e in @($r.errores)) { Write-Host "  ERROR $e" }
  $texto = @{ 0 = 'LIMPIO'; 2 = 'HAY ALGO QUE CONTARLE AL DUENO'; 1 = 'ERROR' }[[int]$r.codigo]
  Write-Host "Resultado: $texto ($($r.codigo))"
}

if (-not $Forzar -and (Test-Path $estadoArchivo)) {
  try {
    $previo = Get-Content $estadoArchivo -Raw | ConvertFrom-Json
    if ($previo.fecha -eq $hoy) {
      Write-Host '(resultado de hoy; -Forzar para volver a medir)'
      Escribir-Resumen $previo
      exit ([int]$previo.codigo)
    }
  } catch { }
}

$errores = New-Object System.Collections.ArrayList

# --- 1) OSV-Scanner ------------------------------------------------------------
$osv = [ordered]@{ paquetes = 0; hallazgos = @(); avisos = @() }
$locks = @('pubspec.lock', 'rust/Cargo.lock') | Where-Object { Test-Path (Join-Path $raiz $_) }
$argsLock = @()
foreach ($l in $locks) { $argsLock += @('-L', "/src/$l") }
$salidaOsv = & podman run --rm -v "${raiz}:/src:ro" $Imagen scan source @argsLock --format json 2>$null | Out-String
$codigoOsv = $LASTEXITCODE
# osv-scanner: 0 sin vulnerabilidades, 1 con vulnerabilidades, otro = error
if ($codigoOsv -ne 0 -and $codigoOsv -ne 1) {
  [void]$errores.Add("osv-scanner salio con $codigoOsv (podman machine start?)")
} else {
  try {
    $json = $salidaOsv | ConvertFrom-Json
    $hallazgos = @(); $avisos = @()
    foreach ($res in @($json.results)) {
      foreach ($p in @($res.packages)) {
        foreach ($g in @($p.groups)) {
          $sev = 0.0
          [void][double]::TryParse([string]$g.max_severity, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$sev)
          $fijo = $null
          foreach ($v in @($p.vulnerabilities)) {
            if (@($g.ids) -notcontains $v.id) { continue }
            foreach ($a in @($v.affected)) {
              foreach ($rg in @($a.ranges)) {
                foreach ($ev in @($rg.events)) { if ($ev.fixed) { $fijo = $ev.fixed } }
              }
            }
          }
          $id = (@($g.ids) -join ',')
          $linea = "$($p.package.name) $($p.package.version) ($($p.package.ecosystem)): $id, severidad $($g.max_severity)"
          if ($fijo) { $linea += ", arreglado en $fijo" } else { $linea += ', sin arreglo' }
          if ($sev -ge $Umbral -and $fijo) { $hallazgos += $linea } else { $avisos += $linea }
        }
      }
    }
    $osv.hallazgos = $hallazgos
    $osv.avisos = $avisos
  } catch {
    [void]$errores.Add("no se pudo leer la salida de osv-scanner: $($_.Exception.Message)")
  }
  # Cuenta de paquetes escaneados (osv-scanner la da por stderr; se recalcula de los lockfiles).
  $total = 0
  foreach ($l in $locks) {
    $t = Get-Content (Join-Path $raiz $l) -Raw
    if ($l -like '*pubspec.lock') { $total += ([regex]::Matches($t, '(?m)^    version: ')).Count }
    else { $total += ([regex]::Matches($t, '(?m)^\[\[package\]\]')).Count }
  }
  $osv.paquetes = $total
}

# --- 2) flutter pub outdated ----------------------------------------------------
$pub = [ordered]@{ compatibles = @(); mayores = @(); descontinuados = @() }
Push-Location $raiz
$salidaPub = & flutter pub outdated --json 2>$null | Out-String
$codigoPub = $LASTEXITCODE
Pop-Location
if ($codigoPub -ne 0) {
  [void]$errores.Add("flutter pub outdated salio con $codigoPub")
} else {
  try {
    $inicio = $salidaPub.IndexOf('{')
    $po = $salidaPub.Substring($inicio) | ConvertFrom-Json
    foreach ($p in @($po.packages)) {
      $actual = $p.current.version
      if (-not $actual) { continue }
      if ($p.isDiscontinued) { $pub.descontinuados += $p.package }
      if ($p.kind -eq 'transitive') { continue }
      if ($p.upgradable.version -and $p.upgradable.version -ne $actual) {
        $pub.compatibles += "$($p.package) $actual -> $($p.upgradable.version)"
      }
      $ultima = $p.latest.version
      if ($ultima -and $ultima -ne $actual) {
        $ma = ($actual -split '[.+-]')
        $mu = ($ultima -split '[.+-]')
        $mayor = if ($ma[0] -eq '0') { $ma[1] -ne $mu[1] -or $mu[0] -ne '0' } else { $ma[0] -ne $mu[0] }
        if ($mayor) { $pub.mayores += "$($p.package) $actual -> $ultima" }
      }
    }
  } catch {
    [void]$errores.Add("no se pudo leer la salida de pub outdated: $($_.Exception.Message)")
  }
}

# --- 3) Dependabot -------------------------------------------------------------
$dep = [ordered]@{ estado = 'sin medir'; abiertas = @() }
$remoto = (& git -C $raiz remote get-url origin 2>$null | Out-String).Trim()
$m = [regex]::Match($remoto, 'github\.com[:/]([^/]+)/([^/.]+)')
if (-not $m.Success) {
  [void]$errores.Add("no se reconoce el remoto de GitHub: $remoto")
} else {
  $repo = "$($m.Groups[1].Value)/$($m.Groups[2].Value)"
  $salidaGh = & gh api "repos/$repo/dependabot/alerts?state=open&per_page=100" 2>&1 | Out-String
  if ($LASTEXITCODE -eq 0) {
    $dep.estado = 'encendidas'
    try {
      foreach ($a in @($salidaGh | ConvertFrom-Json)) {
        $dep.abiertas += "#$($a.number) $($a.dependency.package.name) ($($a.security_advisory.severity)): $($a.security_advisory.summary)"
      }
    } catch { [void]$errores.Add("no se pudo leer la respuesta de Dependabot: $($_.Exception.Message)") }
  } elseif ($salidaGh -match 'disabled') {
    $dep.estado = 'apagadas (PLA-7)'
  } else {
    [void]$errores.Add("gh api de Dependabot fallo: $($salidaGh.Trim())")
  }
}

# --- Resultado -----------------------------------------------------------------
$codigo = 0
if (@($osv.hallazgos).Count -gt 0 -or @($pub.descontinuados).Count -gt 0 -or @($dep.abiertas).Count -gt 0) { $codigo = 2 }
if ($errores.Count -gt 0) { $codigo = 1 }

$resultado = [ordered]@{
  fecha      = $hoy
  codigo     = $codigo
  imagen     = $Imagen
  osv        = $osv
  pub        = $pub
  dependabot = $dep
  errores    = @($errores)
}
if (-not (Test-Path $estadoDir)) { New-Item -ItemType Directory -Path $estadoDir | Out-Null }
($resultado | ConvertTo-Json -Depth 6) | Set-Content -Path $estadoArchivo -Encoding UTF8

Escribir-Resumen ([pscustomobject]$resultado)
exit $codigo
