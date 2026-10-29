# Draws Paintbox's program icon at every size the platforms take and
# writes it where each build reads it: the Windows .ico (PNG-compressed
# entries), the macOS AppIcon set, and packaging/icons for the MSIX
# tiles, the Linux .desktop entry and the AppImage. Run again after
# changing the drawing; the outputs are committed.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$app = Join-Path $root "app"
$icons = Join-Path $root "packaging\icons"
New-Item -ItemType Directory -Force $icons | Out-Null

function New-RoundedRect([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = 2 * $r
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

# The drawing on a 1024 grid: a deep blue tile, a white brush stroke
# sweeping up to the right and a drop of the accent at its tip.
function Get-IconPng([int]$size) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $k = $size / 1024.0
    $g.ScaleTransform($k, $k)

    $tile = New-RoundedRect 64 64 896 896 200
    $top = [System.Drawing.Color]::FromArgb(255, 58, 104, 214)
    $bottom = [System.Drawing.Color]::FromArgb(255, 22, 36, 82)
    $fill = New-Object System.Drawing.Drawing2D.LinearGradientBrush ([System.Drawing.PointF]::new(0, 64)), ([System.Drawing.PointF]::new(0, 960)), $top, $bottom
    $g.FillPath($fill, $tile)
    $rim = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 255, 255, 255)), 12
    $g.DrawPath($rim, $tile)

    $stroke = New-Object System.Drawing.Drawing2D.GraphicsPath
    $stroke.AddBezier(230, 770, 380, 560, 520, 780, 660, 430)
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 120
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawPath($pen, $stroke)

    $accent = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 196, 82))
    $g.FillEllipse($accent, 730, 160, 130, 130)

    $g.Dispose()
    $stream = New-Object System.IO.MemoryStream
    $bmp.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    return , $stream.ToArray()
}

function Write-Png([int]$size, [string]$path) {
    [System.IO.File]::WriteAllBytes($path, (Get-IconPng $size))
}

# Windows: an .ico of PNG entries (Vista and later read them at any size).
$sizes = 16, 20, 24, 32, 40, 48, 64, 128, 256
$images = foreach ($s in $sizes) { , (Get-IconPng $s) }
$ico = New-Object System.IO.MemoryStream
$w = New-Object System.IO.BinaryWriter $ico
$w.Write([UInt16]0); $w.Write([UInt16]1); $w.Write([UInt16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $s = $sizes[$i]
    $dim = if ($s -ge 256) { 0 } else { $s }
    $w.Write([Byte]$dim); $w.Write([Byte]$dim); $w.Write([Byte]0); $w.Write([Byte]0)
    $w.Write([UInt16]1); $w.Write([UInt16]32)
    $w.Write([UInt32]$images[$i].Length); $w.Write([UInt32]$offset)
    $offset += $images[$i].Length
}
foreach ($img in $images) { $w.Write($img) }
$w.Flush()
[System.IO.File]::WriteAllBytes((Join-Path $app "windows\runner\resources\app_icon.ico"), $ico.ToArray())

# macOS: the AppIcon set's files keep their names.
$set = Join-Path $app "macos\Runner\Assets.xcassets\AppIcon.appiconset"
foreach ($s in 16, 32, 64, 128, 256, 512, 1024) {
    Write-Png $s (Join-Path $set "app_icon_$s.png")
}

# MSIX tiles, the Linux icon theme sizes and a large master.
foreach ($s in 44, 48, 50, 64, 128, 150, 256, 512, 1024) {
    Write-Png $s (Join-Path $icons "paintbox-$s.png")
}
Write-Output "icons: ok"
