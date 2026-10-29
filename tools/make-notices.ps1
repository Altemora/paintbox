# Collects the license texts of every Rust crate linked into the program
# (the bridge's normal dependencies, the core's included) into
# app/assets/licenses/rust-crates.txt. The program ships the file and
# shows it on its licenses page next to the Dart packages Flutter lists
# itself. Run again after changing Rust dependencies; the output is
# committed.
$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$out = Join-Path $root "app\assets\licenses\rust-crates.txt"
$env:Path = "$env:USERPROFILE\.cargo\bin;" + $env:Path

Push-Location $root
try {
    $tree = cargo tree -p paintbox_bridge -e normal --prefix none -f "{p}" --target all
    if ($LASTEXITCODE -ne 0) { throw "cargo tree failed ($LASTEXITCODE)" }
    $metadata = cargo metadata --format-version 1 | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) { throw "cargo metadata failed ($LASTEXITCODE)" }
} finally {
    Pop-Location
}

# "name v1.2.3 (path)" lines, each crate once, Paintbox's own left out.
$wanted = @{}
foreach ($line in $tree) {
    if ($line -match '^(\S+) v(\S+)') {
        if (-not $Matches[1].StartsWith("paintbox_")) { $wanted["$($Matches[1]) $($Matches[2])"] = $true }
    }
}

$text = New-Object System.Text.StringBuilder
$packages = $metadata.packages | Sort-Object name, version
foreach ($package in $packages) {
    if (-not $wanted.ContainsKey("$($package.name) $($package.version)")) { continue }
    $dir = Split-Path $package.manifest_path
    $files = Get-ChildItem -Path $dir -File |
        Where-Object { $_.Name -match '^(LICEN[CS]E|COPYING|NOTICE|UNLICENSE)' } |
        Sort-Object Name
    $license = if ($package.license) { $package.license } else { "see the files below" }
    # One entry per crate: its name line, the texts, a separator line the
    # program splits on.
    [void]$text.AppendLine("$($package.name) $($package.version)")
    [void]$text.AppendLine("License: $license")
    [void]$text.AppendLine()
    if (-not $files) {
        [void]$text.AppendLine("The crate ships no license file; its license is $license.")
    }
    foreach ($file in $files) {
        [void]$text.AppendLine("--- $($file.Name)")
        [void]$text.AppendLine((Get-Content -Raw -Encoding UTF8 $file.FullName).TrimEnd())
        [void]$text.AppendLine()
    }
    [void]$text.AppendLine("================================================================")
}

New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null
[System.IO.File]::WriteAllText($out, ($text.ToString() -replace "`r`n", "`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Output "notices: $($wanted.Count) crates -> $out"
