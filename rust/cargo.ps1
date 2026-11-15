# Corre cargo dentro de Podman (Rust no va al host, ADR-0012). Monta la raiz del repo (las pruebas leen vectores/).
# Uso: .\rust\cargo.ps1 test            .\rust\cargo.ps1 clippy --all-targets -- -D warnings
# Limpieza: podman volume rm solokey-cargo-registry solokey-cargo-target
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$CargoArgs)
$img = 'docker.io/library/rust:1.91-slim-bookworm'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
podman run --rm -v "${repo}:/repo" -w /repo/rust `
  -v solokey-cargo-registry:/usr/local/cargo/registry `
  -v solokey-cargo-target:/repo/rust/target `
  $img cargo @CargoArgs
exit $LASTEXITCODE
