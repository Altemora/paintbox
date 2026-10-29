# Puts Paintbox into the Start menu (the user's own Programs folder, no
# elevation): a shortcut to the release build in app/build, so it is
# current after every `flutter build windows --release` without an
# install. Re-run after moving the repository.
#   tools/make-shortcut.ps1 [-Desktop]
param(
    # Also puts the shortcut on the desktop.
    [switch]$Desktop
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$exe = Join-Path $root "app\build\windows\x64\runner\Release\paintbox.exe"
$icon = Join-Path $root "app\windows\runner\resources\app_icon.ico"
if (-not (Test-Path $exe)) { throw "no release build at $exe (flutter build windows --release first)" }

$shell = New-Object -ComObject WScript.Shell
function Make-Shortcut([string]$Where) {
    $link = $shell.CreateShortcut((Join-Path $Where "Paintbox.lnk"))
    $link.TargetPath = $exe
    $link.WorkingDirectory = Split-Path $exe
    $link.Description = "Paintbox, a layered image editor"
    $link.IconLocation = "$icon,0"
    $link.Save()
    Write-Output ("shortcut: {0} -> {1}" -f (Join-Path $Where "Paintbox.lnk"), $exe)
}

Make-Shortcut ([Environment]::GetFolderPath("Programs"))
if ($Desktop) { Make-Shortcut ([Environment]::GetFolderPath("Desktop")) }
