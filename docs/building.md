# Paintbox: building, checking and packaging

This page explains how to build the program from source, run the checks,
take screenshots of the window and make packages for Windows, Linux and
macOS. How the program is put together is in
[architecture.md](architecture.md).

## Build and run

You need Flutter 3.47 (Dart 3.13) and stable Rust from `rustup`. To
change the bridge you also need `flutter_rust_bridge_codegen` 2.13.0
(`cargo install flutter_rust_bridge_codegen --version 2.13.0`). There is
no separate step for the core: Cargokit, attached to the `paint_bridge`
plugin, runs cargo during `flutter build`.

```
cd app
flutter pub get
flutter run -d windows
flutter build windows --release
```

The release build is `app/build/windows/x64/runner/Release/paintbox.exe`
with `paintbox_bridge.dll` next to it. Command-line arguments are files
to open.

The generated code is committed, so a plain build needs neither code
generator: the bridge bindings (`lib/src/rust` and
`rust/src/frb_generated.rs` in `paint_bridge`) and the localizations
(`lib/src/localization/generated` in `app_ui`). After changing
`packages_tools/paint_bridge/rust/src/api`, run `melos run gen:bridge`;
after changing an arb file, run `melos run gen:l10n`.

## Checks

```
tools/check.ps1 [-Build]
```

The script runs `cargo fmt --check`, `cargo clippy -D warnings` and
`cargo test` for the workspace and builds the bridge library the Flutter
tests load. Then, in `app/`, it runs `flutter pub get`,
`dart analyze --fatal-infos`, the format check and `flutter test` for
every package with tests. With `-Build` it also runs
`flutter build windows --release`. The same by hand:

```
cargo build -p paintbox_bridge
cd app
dart analyze --fatal-infos .
melos run format:check
melos run test
```

The package tests load the bridge that cargo built in the repository's
`target/` folder (`BridgeLoader` in each `test` folder), so blocs and
repositories are tested against the real core rather than a stand-in.

## Screenshots

```
paintbox --screenshot=<path.png> [--scene=<name>] [--theme=dark|light]
         [--accent=blue|green|amber|purple|red|gray] [--language=<code>]
```

The program plays scenes through the same events as user input, saves
`<path>-<scene>.png` for each and quits. Without `--scene` it plays all
of them.

| Scene | What it shows |
|---|---|
| `empty` | The blank image the program starts with. |
| `layers` | An OpenRaster file with two layers (a gradient, and a stroke with an ellipse drawn by the core's tools), opened the way File > Open opens it, with an elliptical selection dragged by the pointer. |
| `effect` | The Gaussian Blur dialog previewing on the selection. |
| `text`, `lines`, `transform` | The Text tool; line ends and dash styles; a rotated fragment. |
| `effects` | One picture per effect. |
| `compact` | The Colors window in Less mode and the Text tool's settings. |
| `strips` | The tool bar of each kind of tool (`strip-<tool>`). |

Screenshots neither read nor write the user's settings, and the
clipboard is kept in memory. The theme, accent and language come from
the options: dark, blue and English by default. The screenshots in the
README are made this way into `docs/images`.

## Packaging

There is no platform-specific code outside the plugins
(`window_manager`, `file_selector`, `pasteboard`, `desktop_drop`) and
Cargokit, and the program looks the same on every platform. The
application ID is `dev.paintbox.Paintbox` (Linux `APPLICATION_ID`, macOS
`PRODUCT_BUNDLE_IDENTIFIER`, the .desktop and AppStream names); the
window and the packages are called Paintbox. `tools/make-icons.ps1`
draws the icon (a blue tile, a white brush stroke and a yellow drop) and
writes every size: `app/windows/runner/resources/app_icon.ico`, the
macOS `AppIcon` set, and `packaging/icons` for MSIX and Linux. Finished
packages go to `dist/`, which git ignores. Every package carries
`LICENSE`, `NOTICE.md` and `LICENSES/`.

### Windows

```
tools/package-windows.ps1 [-SkipBuild] [-CertificatePath <pfx> -CertificatePassword <password> -Publisher "CN=..."]
```

The script runs `flutter build windows --release` (the standard runner
opens no console; one appears only under a debugger) and removes
`data/flutter_assets/kernel_blob.bin` from its copy. That file is the
Dart kernel a debug run leaves in the shared assets folder; a release
runs the AOT `app.so` instead. It then makes:

- **A portable zip**, `Paintbox-<version>-windows-x64.zip`: the build
  folder as it is (`paintbox.exe`, `paintbox_bridge.dll`,
  `flutter_windows.dll`, the plugins, `data`), written with Windows' own
  `tar` so that entry names use the standard `/` (Windows PowerShell's
  `Compress-Archive` writes `\`). Unpack it and run.
- **An MSIX**, `Paintbox-<version>-windows-x64.msix`, made with
  `makeappx` from the Windows SDK and the manifest
  `packaging/windows/AppxManifest.xml` (full trust; associations for
  .ora, .png, .jpg, .bmp, .tga and .webp; tiles from the icon). Windows
  does not install an **unsigned** MSIX. Signing needs a code-signing
  certificate (.pfx) whose subject matches the manifest's `Publisher`:
  one from a certificate authority (OV or EV) for distribution, or a
  self-signed one for your own machines
  (`New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=Paintbox"`,
  added to the machine's Trusted People). Given `-CertificatePath`, the
  script signs with `signtool` from the same SDK folder and a timestamp,
  so the signature stays valid after the certificate expires. The
  Microsoft Store signs packages itself.
- **An Inno Setup installer**, `Paintbox-<version>-windows-x64-setup.exe`,
  from `packaging/windows/paintbox.iss`, only when Inno Setup 6 is
  installed (`winget install JRSoftware.InnoSetup`); otherwise the step
  is skipped with a message. The installer shows the license, installs
  for the current user without administrator rights (its dialog also
  offers all users), adds a Start menu shortcut and optionally a desktop
  shortcut and the .ora association. SmartScreen warns about an unsigned
  installer; sign it with the same certificate (`signtool sign` on the
  finished .exe, or `SignTool=` in the script).

The version comes from `app/pubspec.yaml` (`0.1.0+1` becomes MSIX
`0.1.0.1`).

### Linux

```
packaging/linux/build-appimage.sh
```

The script runs `flutter build linux --release` and packs the AppImage
`Paintbox-<version>-linux-<arch>.AppImage` with `linuxdeploy`, which it
downloads into `dist/tools` unless the `LINUXDEPLOY` variable points to
one. The package gets the .desktop file and the AppStream description
from `packaging/linux` and hicolor icons from 48 to 512 pixels.
linuxdeploy comes from its `continuous` release; pin a version through
`LINUXDEPLOY` for a reproducible build.

Building needs Flutter 3.47 for Linux, Rust, `clang`, `cmake`,
`ninja-build`, `pkg-config`, `libgtk-3-dev` (which `window_manager` and
`screen_retriever` also need) and `curl`. Running needs GTK 3
(`libgtk-3-0`), `libglib2.0-0` and `libstdc++6`, and the AppImage also
needs `libfuse2` (or `--appimage-extract-and-run`). The GTK libraries
stay the system's: the script excludes GTK, GDK, Pango, Cairo, ATK,
HarfBuzz and epoxy, because bundled copies break on other distributions
without the GTK plugin environment. The plugins' `.so` files and
`libpaintbox_bridge.so` travel in the package.

On Linux, `file_selector` shows the GTK dialog. `pasteboard` cannot
write images to the clipboard there (it only reads them), so copying
into other programs does not work until the plugin is replaced
(`super_clipboard` is a candidate). Dropping files under Wayland and
mouse wheel scaling still need checking on a real machine.

**Not yet run**: the script is written but has not been run, because no
Linux machine with Flutter has been available.

### macOS

```
SIGN_IDENTITY="Developer ID Application: <name> (<team id>)" NOTARY_PROFILE=paintbox packaging/macos/package-macos.sh
```

The script runs `flutter build macos --release`, which produces
`Paintbox.app`: Cargokit builds the core through `build_pod.sh` for both
architectures and links it as a static library into
`paint_bridge.framework`. This needs Xcode and
`rustup target add aarch64-apple-darwin x86_64-apple-darwin`. The script
then signs from the inside out (`find -depth`: nested items before their
framework, then the app) with the hardened runtime and
`Release.entitlements`, submits a zip for notarization
(`xcrun notarytool submit --wait`), staples the ticket
(`stapler staple`) and makes a zip and a dmg. Without `SIGN_IDENTITY` it
stops after the build. You need an Apple Developer account, a "Developer
ID Application" certificate in the keychain and a profile from
`notarytool store-credentials`.

The entitlements (`macos/Runner/*.entitlements`) have no sandbox. The
program is distributed with a Developer ID rather than through the Mac
App Store, so the sandbox is not required, and with it saving would not
work: a file is written next to its target as `<name>.part` and then
renamed, while the sandbox grants access only to the chosen file, not to
its folder. Recent files would also need security-scoped bookmarks after
a restart. The hardened runtime for notarization comes from the
`codesign` options. DebugProfile keeps `allow-jit` and `network.server`
for Flutter debugging. The Mac App Store would need the sandbox,
`files.user-selected.read-write`, writing in place instead of through
`.part`, and bookmarks for recent files. On macOS, Ctrl in the program's
shortcuts also accepts Cmd.

**Not yet run**: the script is written but has not been run, because no
Mac has been available.
