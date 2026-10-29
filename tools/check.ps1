# The verification every change runs: Rust format, clippy and tests for
# the workspace (the core and the bridge), the bridge library the Flutter
# tests load, then the Flutter program analysed, format-checked and
# tested. -Build also makes the Windows release build.
param(
    [switch]$Build
)

# "Continue": cargo and flutter write progress to stderr, and Windows
# PowerShell would turn that into a terminating error under "Stop". Exit
# codes decide.
$ErrorActionPreference = "Continue"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$env:Path = "$env:USERPROFILE\.cargo\bin;" + $env:Path

function Step($name, [scriptblock]$body) {
    Write-Output ""
    Write-Output "== $name"
    & $body
    if ($LASTEXITCODE -ne 0) { throw "$name failed ($LASTEXITCODE)" }
}

Push-Location $root
try {
    Step "cargo fmt" { cargo fmt --all -- --check }
    Step "cargo clippy" { cargo clippy --all-targets -- -D warnings }
    Step "cargo test" { cargo test }
    # The Flutter tests load the bridge cargo builds here.
    Step "bridge build" { cargo build -p paintbox_bridge }
} finally {
    Pop-Location
}

Push-Location (Join-Path $root "app")
try {
    Step "pub get" { flutter pub get }
    Step "analyze" { dart analyze --fatal-infos . }
    Step "format" {
        dart format --output=none --set-exit-if-changed lib packages_tools/core packages_tools/paint_bridge/lib packages_logic packages_ui
    }
    foreach ($package in @("packages_logic\paint_logic", "packages_ui\app_ui", "packages_ui\editor_ui")) {
        if (-not (Test-Path (Join-Path $package "test"))) { continue }
        Push-Location $package
        try {
            Step "test $package" { flutter test }
        } finally {
            Pop-Location
        }
    }
    if ($Build) {
        Step "flutter build windows" { flutter build windows --release }
    }
} finally {
    Pop-Location
}

Write-Output ""
Write-Output "check: ok"
