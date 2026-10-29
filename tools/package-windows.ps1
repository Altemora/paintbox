# Packages Paintbox for Windows into dist/: the release build
# (flutter build windows --release), a portable zip, an MSIX (unsigned
# unless -CertificatePath is given) and, when Inno Setup 6 is installed,
# an installer. -SkipBuild packages the build already there. Linux and
# macOS have their own scripts in packaging/ (docs/building.md).
param(
    [switch]$SkipBuild,
    # A .pfx to sign the MSIX with; its subject must equal -Publisher.
    [string]$CertificatePath = "",
    [string]$CertificatePassword = "",
    [string]$Publisher = "CN=Paintbox"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$app = Join-Path $root "app"
$packaging = Join-Path $root "packaging"
$dist = Join-Path $root "dist"
$release = Join-Path $app "build\windows\x64\runner\Release"
$env:Path = "$env:USERPROFILE\.cargo\bin;" + $env:Path

function Step($name, [scriptblock]$body) {
    Write-Output ""
    Write-Output "== $name"
    & $body
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "$name failed ($LASTEXITCODE)" }
}

# A release build reuses build/flutter_assets, where a debug run leaves its
# kernel (tens of MB); the AOT app.so is what runs, so the kernel goes.
function Remove-Stale($dir) {
    $kernel = Join-Path $dir "data\flutter_assets\kernel_blob.bin"
    if (Test-Path $kernel) { Remove-Item -Force $kernel }
}

# pubspec's 0.1.0+1: the version and the build number.
$line = Select-String -Path (Join-Path $app "pubspec.yaml") -Pattern '^version:\s*(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?' | Select-Object -First 1
if (-not $line) { throw "no version in pubspec.yaml" }
$g = $line.Matches[0].Groups
$version = "$($g[1].Value).$($g[2].Value).$($g[3].Value)"
$build = if ($g[4].Success) { $g[4].Value } else { "0" }
$package = "Paintbox-$version-windows-x64"

if (-not $SkipBuild) {
    Push-Location $app
    try {
        Step "flutter build windows --release" { flutter build windows --release }
    } finally {
        Pop-Location
    }
}
if (-not (Test-Path (Join-Path $release "paintbox.exe"))) { throw "no release build in $release" }
New-Item -ItemType Directory -Force $dist | Out-Null

Step "portable zip" {
    $zip = Join-Path $dist "$package.zip"
    $folder = Join-Path $dist $package
    if (Test-Path $folder) { Remove-Item -Recurse -Force $folder }
    Copy-Item -Recurse $release $folder
    Remove-Stale $folder
    if (Test-Path $zip) { Remove-Item -Force $zip }
    # Windows' own tar (bsdtar, Windows 10 and later) writes standard "/"
    # entry names; Compress-Archive in Windows PowerShell writes "\", and
    # Git's GNU tar, often first on PATH, cannot write a zip.
    & (Join-Path $env:SystemRoot "System32\tar.exe") -a -c -f $zip -C $dist $package
    if ($LASTEXITCODE -ne 0) { throw "tar failed ($LASTEXITCODE)" }
    Remove-Item -Recurse -Force $folder
    Write-Output $zip
}

Step "msix" {
    $kits = "${env:ProgramFiles(x86)}\Windows Kits\10\bin"
    $makeappx = Get-ChildItem -Path $kits -Recurse -Filter makeappx.exe -ErrorAction SilentlyContinue |
        Where-Object { $_.DirectoryName -like "*\x64" } | Sort-Object FullName | Select-Object -Last 1
    if (-not $makeappx) {
        Write-Output "skipped: makeappx.exe not found (Windows SDK)"
        return
    }
    $stage = Join-Path $dist "msix-stage"
    if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
    Copy-Item -Recurse $release $stage
    Remove-Stale $stage
    $assets = New-Item -ItemType Directory -Force (Join-Path $stage "Assets")
    $icons = Join-Path $packaging "icons"
    Copy-Item (Join-Path $icons "paintbox-44.png") (Join-Path $assets "Square44x44Logo.png")
    Copy-Item (Join-Path $icons "paintbox-150.png") (Join-Path $assets "Square150x150Logo.png")
    Copy-Item (Join-Path $icons "paintbox-50.png") (Join-Path $assets "StoreLogo.png")
    $manifest = Get-Content -Raw (Join-Path $packaging "windows\AppxManifest.xml")
    $manifest = $manifest.Replace("{VERSION}", "$version.$build").Replace("{PUBLISHER}", $Publisher)
    Set-Content -Path (Join-Path $stage "AppxManifest.xml") -Value $manifest -Encoding UTF8
    $msix = Join-Path $dist "$package.msix"
    & $makeappx.FullName pack /o /d $stage /p $msix /nv | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "makeappx failed ($LASTEXITCODE)" }
    Remove-Item -Recurse -Force $stage
    if ($CertificatePath) {
        $signtool = Join-Path $makeappx.DirectoryName "signtool.exe"
        # A timestamp keeps the signature valid after the certificate expires.
        $sign = @("sign", "/fd", "SHA256", "/f", $CertificatePath, "/tr", "http://timestamp.digicert.com", "/td", "SHA256")
        if ($CertificatePassword) { $sign += @("/p", $CertificatePassword) }
        & $signtool @sign $msix
        if ($LASTEXITCODE -ne 0) { throw "signtool failed ($LASTEXITCODE)" }
    } else {
        Write-Output "unsigned: Windows installs it only once signed (see docs/building.md)"
    }
    $global:LASTEXITCODE = 0
    Write-Output $msix
}

Step "inno setup installer" {
    $iscc = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
        "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $iscc) {
        Write-Output "skipped: Inno Setup 6 is not installed (winget install JRSoftware.InnoSetup)"
        return
    }
    & $iscc "/DAppVersion=$version" "/DSourceDir=$release" "/DOutputDir=$dist" (Join-Path $packaging "windows\paintbox.iss")
}

Write-Output ""
Write-Output "package: ok ($dist)"
