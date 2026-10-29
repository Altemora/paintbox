#!/usr/bin/env bash
# Builds Paintbox for Linux and packs it as an AppImage in dist/ with
# linuxdeploy (downloaded into dist/tools on first use unless
# LINUXDEPLOY points at one). Needs Flutter 3.47 for Linux, Rust and the
# build libraries listed in docs/building.md. Run from anywhere.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"
app="$root/app"
dist="$root/dist"
app_id="dev.paintbox.Paintbox"
version="$(sed -n 's/^version: *\([0-9.]*\).*/\1/p' "$app/pubspec.yaml")"
arch="$(uname -m)"

mkdir -p "$dist/tools"
linuxdeploy="${LINUXDEPLOY:-$dist/tools/linuxdeploy-$arch.AppImage}"
if [ ! -x "$linuxdeploy" ]; then
  curl -fL -o "$linuxdeploy" \
    "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$arch.AppImage"
  chmod +x "$linuxdeploy"
fi

(cd "$app" && flutter build linux --release)
bundle="$app/build/linux/x64/release/bundle"
[ "$arch" = "aarch64" ] && bundle="$app/build/linux/arm64/release/bundle"

appdir="$dist/AppDir"
rm -rf "$appdir"
mkdir -p "$appdir/usr/bin" "$appdir/usr/share/applications" "$appdir/usr/share/metainfo"
# Flutter's bundle keeps lib/ and data/ next to the executable.
cp -r "$bundle"/. "$appdir/usr/bin/"
cp "$here/$app_id.desktop" "$appdir/usr/share/applications/"
cp "$here/$app_id.metainfo.xml" "$appdir/usr/share/metainfo/"
for size in 48 64 128 256 512; do
  icons="$appdir/usr/share/icons/hicolor/${size}x${size}/apps"
  mkdir -p "$icons"
  cp "$root/packaging/icons/paintbox-$size.png" "$icons/$app_id.png"
done

# GTK and its stack stay the system's: bundled without the GTK plugin's
# environment they break on other distributions. The plugins' own .so
# files and the bridge travel with the bundle.
export LDAI_OUTPUT="$dist/Paintbox-$version-linux-$arch.AppImage"
export OUTPUT="$LDAI_OUTPUT"
export VERSION="$version"
"$linuxdeploy" --appimage-extract-and-run \
  --appdir "$appdir" \
  --executable "$appdir/usr/bin/paintbox" \
  --desktop-file "$appdir/usr/share/applications/$app_id.desktop" \
  --icon-file "$root/packaging/icons/paintbox-256.png" \
  --icon-filename "$app_id" \
  --exclude-library 'libgtk-3.so*' --exclude-library 'libgdk-3.so*' \
  --exclude-library 'libgdk_pixbuf-2.0.so*' --exclude-library 'libpango*' \
  --exclude-library 'libcairo*' --exclude-library 'libatk*' \
  --exclude-library 'libharfbuzz.so*' --exclude-library 'libepoxy.so*' \
  --output appimage
rm -rf "$appdir"
echo "appimage: $OUTPUT"
