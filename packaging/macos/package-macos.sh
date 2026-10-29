#!/usr/bin/env bash
# Builds Paintbox.app for macOS, signs it with a Developer ID, has Apple
# notarise it and staples the ticket, then makes a zip and a dmg in
# dist/. Needs a Mac with Xcode, Flutter 3.47, Rust with both Apple
# targets (rustup target add aarch64-apple-darwin x86_64-apple-darwin),
# a "Developer ID Application" certificate in the keychain and a
# notarytool profile:
#
#   xcrun notarytool store-credentials paintbox \
#     --apple-id <apple id> --team-id <team id> --password <app password>
#
#   SIGN_IDENTITY="Developer ID Application: <name> (<team id>)" \
#   NOTARY_PROFILE=paintbox packaging/macos/package-macos.sh
#
# Without SIGN_IDENTITY it stops after the unsigned build (ad hoc signed,
# runs only on the machine that built it).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"
app_dir="$root/app"
dist="$root/dist"
version="$(sed -n 's/^version: *\([0-9.]*\).*/\1/p' "$app_dir/pubspec.yaml")"
entitlements="$app_dir/macos/Runner/Release.entitlements"

(cd "$app_dir" && flutter build macos --release)
app="$app_dir/build/macos/Build/Products/Release/Paintbox.app"
# The license and the notices travel inside the bundle (before signing).
cp -r "$root/LICENSE" "$root/NOTICE.md" "$root/LICENSES" "$app/Contents/Resources/"
mkdir -p "$dist"

if [ -z "${SIGN_IDENTITY:-}" ]; then
  echo "unsigned build: $app"
  exit 0
fi

# Inside out (-depth: what a framework holds before the framework; the
# bridge is linked into paint_bridge.framework), then the app,
# all with the hardened runtime notarisation requires.
find "$app/Contents/Frameworks" -depth \( -name "*.dylib" -o -name "*.framework" \) -print0 |
  while IFS= read -r -d '' item; do
    codesign --force --timestamp --options runtime --sign "$SIGN_IDENTITY" "$item"
  done
codesign --force --timestamp --options runtime --entitlements "$entitlements" \
  --sign "$SIGN_IDENTITY" "$app"
codesign --verify --deep --strict --verbose=2 "$app"

zip="$dist/Paintbox-$version-macos.zip"
ditto -c -k --keepParent "$app" "$zip"
xcrun notarytool submit "$zip" --keychain-profile "${NOTARY_PROFILE:?set NOTARY_PROFILE}" --wait
xcrun stapler staple "$app"
# The zip again, now with the stapled ticket inside.
rm -f "$zip"
ditto -c -k --keepParent "$app" "$zip"

dmg="$dist/Paintbox-$version-macos.dmg"
rm -f "$dmg"
hdiutil create -volname Paintbox -srcfolder "$app" -ov -format UDZO "$dmg"
codesign --force --timestamp --sign "$SIGN_IDENTITY" "$dmg"
xcrun notarytool submit "$dmg" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$dmg"
spctl --assess --type open --context context:primary-signature --verbose "$dmg"
echo "macos: $zip $dmg"
