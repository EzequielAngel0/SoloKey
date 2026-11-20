<#
.SYNOPSIS
  Compila SoloKey en Podman (PLA-3): APK de Android, librerias nativas del nucleo Rust y el
  E2E de Android en un emulador desechable.

.DESCRIPTION
  Nada de esto va al host (ADR-0012): ni el SDK ni el NDK de Android, ni Rust.
    1) Lee flutter-version de .github/workflows/tests.yml y, si falta, construye la imagen
       localhost/solokey-build:<version>-<receta> (tool/build/Containerfile; <receta> es el
       hash del Containerfile, asi un cambio en la receta construye una imagen nueva). Con
       -E2e usa la etapa e2e: localhost/solokey-e2e:<version>-<receta> (lleva el emulador).
    2) Monta el repo en solo lectura y lo COPIA dentro del contenedor (sin build/, .dart_tool/,
       .git, local.properties ni rust/target): pub get y Gradle escriben rutas de Linux.
    3) Corre el -Comando (por defecto, el APK release) y deja lo que copie a /out en -Salida.
  Caches en volumenes con nombre: solokey-pub-cache (Pub, compartido con ci-linux.ps1),
  solokey-gradle, solokey-cargo-registry (compartido con rust/cargo.ps1), solokey-xwin (CRT y
  SDK de Windows que baja cargo-xwin) y solokey-build-target (target de Cargo). Limpieza:
    podman images --filter reference=localhost/solokey-e2e -q | % { podman rmi $_ }
    podman images --filter reference=localhost/solokey-build -q | % { podman rmi $_ }
    podman volume rm solokey-gradle solokey-xwin solokey-build-target
  Archivo en ASCII (PowerShell 5.1).

.PARAMETER Comando
  Comandos de bash a correr en /work tras pub get. $SALIDA apunta a /out.

.PARAMETER Nucleo
  En vez del APK, compila solokey-core: .so por ABI (cargo-ndk) en <Salida>\jniLibs y
  solokey_core.dll (cargo-xwin) en <Salida>.

.PARAMETER E2e
  Corre integration_test/ en un emulador de Android NUEVO dentro del contenedor (KVM de la VM
  de Podman). El emulador nace vacio y muere con el contenedor: aqui si se permite borrar la
  boveda (E2E_ALLOW_WIPE). No toca el emulador ni el celular del host.

.PARAMETER Salida
  Carpeta del host montada con escritura en /out. Por defecto build\podman del repo.

.PARAMETER Reconstruir
  Reconstruye la imagen aunque exista.

.EXAMPLE
  .\tool\build.ps1
  .\tool\build.ps1 -Nucleo
  .\tool\build.ps1 -E2e
  .\tool\build.ps1 -Comando 'flutter build apk --debug && cp build/app/outputs/flutter-apk/*.apk $SALIDA/'
#>
[CmdletBinding()]
param(
  [string]$Comando = '',
  [switch]$Nucleo,
  [switch]$E2e,
  [string]$Salida = '',
  [switch]$Reconstruir
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$yml = Get-Content -LiteralPath (Join-Path $repo '.github\workflows\tests.yml') -Raw
$ver = ([regex]::Match($yml, "flutter-version:\s*'([^']+)'")).Groups[1].Value
if (-not $ver) { throw 'No se pudo leer flutter-version de .github/workflows/tests.yml' }
$receta = Join-Path $repo 'tool\build\Containerfile'
$hash = (Get-FileHash -LiteralPath $receta -Algorithm SHA256).Hash.Substring(0, 8).ToLower()
$etapa = 'build'
if ($E2e) { $etapa = 'e2e' }
$image = "localhost/solokey-${etapa}:$ver-$hash"

& podman image exists $image
if ($Reconstruir -or $LASTEXITCODE -ne 0) {
  Write-Host "[build] construyendo $image (la primera vez tarda: Flutter, SDK, NDK y Rust)" -ForegroundColor Cyan
    # --jobs: Rust, Flutter y el SDK son etapas independientes y se construyen a la vez.
  & podman build -t $image --target $etapa --jobs 4 --build-arg "FLUTTER_VERSION=$ver" -f $receta (Join-Path $repo 'tool\build')
  if ($LASTEXITCODE -ne 0) { Write-Host 'FALLO la construccion de la imagen' -ForegroundColor Red; exit 1 }
}

if ($Nucleo) {
  $Comando = @'
cd rust
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -o "$SALIDA/jniLibs" build --release -p solokey-core
cargo xwin build --release --target x86_64-pc-windows-msvc -p solokey-core
cp "$CARGO_TARGET_DIR/x86_64-pc-windows-msvc/release/solokey_core.dll" "$SALIDA/"
'@
} elseif ($E2e) {
  $Comando = @'
emulator -avd e2e -no-window -no-audio -no-boot-anim -no-snapshot -wipe-data -gpu swiftshader_indirect > /tmp/emulator.log 2>&1 &
adb wait-for-device
for i in $(seq 1 120); do
  [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ] && break
  sleep 3
done
[ "$(adb shell getprop sys.boot_completed | tr -d '\r')" = 1 ] || { tail -50 /tmp/emulator.log; exit 1; }
for s in window_animation_scale transition_animation_scale animator_duration_scale; do adb shell settings put global $s 0; done
# La app pide el permiso de notificaciones antes de runApp y en Android 13+ espera a que se
# conteste. flutter test desinstala la app al acabar cada archivo, asi que va uno por uno: antes
# de cada uno se instala con -g (permisos concedidos) y flutter test reinstala encima sin perderlos.
flutter build apk --debug
adb logcat -c
fallo=0
for f in integration_test/*_test.dart; do
  adb install -g build/app/outputs/flutter-apk/app-debug.apk > /dev/null
  timeout 900 flutter test "$f" -d emulator-5554 --dart-define=E2E_ALLOW_WIPE=1 --dart-define=TEST_DISABLE_BIOMETRIC=1 || fallo=1
done
if [ "$fallo" -ne 0 ]; then adb logcat -d > "$SALIDA/logcat.txt"; echo "logcat del emulador en <Salida>/logcat.txt"; exit 1; fi
'@
} elseif (-not $Comando) {
  $Comando = 'flutter build apk --release && cp build/app/outputs/flutter-apk/app-release.apk "$SALIDA/"'
}
$bash = @"
set -eo pipefail
mkdir -p /work
tar -C /src --exclude=./.git --exclude=./build --exclude=./.dart_tool --exclude=./coverage --exclude=./dist \
  --exclude=./android/.gradle --exclude=./android/local.properties --exclude=./rust/target --exclude=./.claude \
  -cf - . | tar -C /work -xf -
cd /work
flutter pub get > /tmp/pub.log 2>&1 || { cat /tmp/pub.log; exit 1; }
$Comando
"@

# El script va en un archivo montado, no como argumento: PowerShell 5.1 rompe las comillas
# dobles al pasarlas a un ejecutable nativo. LF y UTF-8 sin BOM para bash.
$script = Join-Path ([IO.Path]::GetTempPath()) ("solokey-build-" + [guid]::NewGuid().ToString('N') + '.sh')
[IO.File]::WriteAllText($script, ($bash -replace "`r", ''), (New-Object Text.UTF8Encoding $false))

if (-not $Salida) { $Salida = Join-Path $repo 'build\podman' }
New-Item -ItemType Directory -Force -Path $Salida | Out-Null
$salidaAbs = (Resolve-Path $Salida).Path

$runArgs = @('run', '--rm',
  '-v', "$(($repo -replace '\\', '/')):/src:ro",
  '-v', "$(($salidaAbs -replace '\\', '/')):/out", '-e', 'SALIDA=/out',
  '-v', "$(($script -replace '\\', '/')):/build.sh:ro",
  '-v', 'solokey-pub-cache:/pub-cache',
  '-v', 'solokey-gradle:/gradle',
  '-v', 'solokey-cargo-registry:/opt/cargo/registry',
  '-v', 'solokey-xwin:/xwin-cache',
  '-v', 'solokey-build-target:/cargo-target')
if ($E2e) { $runArgs += @('--device', '/dev/kvm') }
$runArgs += @($image, 'bash', '/build.sh')

Write-Host "[build] $image -> $salidaAbs" -ForegroundColor Cyan
try { & podman @runArgs; $code = $LASTEXITCODE } finally { Remove-Item -LiteralPath $script -Force -ErrorAction SilentlyContinue }
if ($code -ne 0) { Write-Host "[build] FALLO (salida $code)" -ForegroundColor Red; exit $code }
Write-Host "[build] listo en $salidaAbs" -ForegroundColor Green
