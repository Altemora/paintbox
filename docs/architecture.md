# Paintbox: architecture

Paintbox is a Flutter program (`app/`) over a Rust core with no UI
(`crates/paintbox_core`). This page describes how the pieces fit
together. What the tools, keys and menus do is in
[behaviour.md](behaviour.md); building and running are in
[building.md](building.md); the code rules are in
[CONTRIBUTING.md](../CONTRIBUTING.md).

## Repository

| Path | Contents |
|---|---|
| `Cargo.toml` | The Rust workspace: the core and the bridge. |
| `crates/paintbox_core` | The core: document, layers, blending, selection, history, tools, adjustments, effects, files. |
| `app/` | The Flutter program (a melos monorepo) with the bridge to the core. |
| `tools/` | `check.ps1` (all checks), `package-windows.ps1` (Windows packages), `make-icons.ps1` (the program icon). |
| `packaging/` | Manifests and scripts for the Windows, Linux and macOS packages, and the icons. |
| `docs/` | This documentation and the README screenshots (`docs/images`). |

## Core

`paintbox_core` knows nothing about a UI toolkit. A front end keeps one
`Session` per open image and only translates its own types into the
session's calls, so behaviour such as "the other button during a drag
moves the shape" or "Enter with nothing in progress deselects" lives in
the core and is the same in any front end.

| Modules | Contents |
|---|---|
| `document`, `layer`, `blend` | The document, the layer stack, Paint.NET's 14 blend modes, tiled compositing. |
| `selection`, `mask`, `select` | The selection as a coverage mask with an outline, combine modes, the magic wand. |
| `history` | Undo history that stores the tiles before and after each change. |
| `tool`, `tools`, `gesture`, `stroke`, `raster`, `text`, `typing` | The Paint.NET tools, the gesture controller, strokes, shapes and text. |
| `adjust`, `effects/` | Adjustments and effects (blurs, distortions, noise, photo, render, stylize, artistic). |
| `command`, `session`, `preview` | Menu commands with keys and availability, the per-image session, previewing dialogs rendered on a worker thread. |
| `files`, `clipboard`, `palette` | OpenRaster and flat image formats, the clipboard, the palette. |

The core's tests live next to the code and in
`crates/paintbox_core/tests`: `shell_flow` walks the path a front end
takes, and `perf_4k` checks speed on a 4K image.

## Program

The program is a melos monorepo on pub workspaces (melos 7). Packages
form three layers, `packages_tools` ← `packages_logic` ← `packages_ui`,
and `app/lib/` is the composition root.

| Package | Contents |
|---|---|
| `packages_tools/core` | `Failure` (sealed), `AppLog`, `injector`, `EventBusService` and `ShowFailureAction`. |
| `packages_tools/paint_bridge` | The core for Dart: the Rust crate `paintbox_bridge` (`rust/`, a member of the root Cargo workspace), the generated bindings (`lib/src/rust`), Cargokit and the plugin for Windows, Linux and macOS. |
| `packages_logic/paint_logic` | `PaintCall` (turns core failures into `Failure` in one place), open images (`ImagesRepository`), settings and recent files (`SettingsRepository`, JSON in the application support folder), the clipboard (`ClipboardRepository` over `pasteboard`), file dialogs (`file_selector`), the canvas view (`CanvasView`), the core's catalog (`PaintCatalog`). |
| `packages_ui/app_ui` | Theme, tokens and accent palette, glass surfaces, toasts, dialogs, `ActionListener`, gen-l10n (English template and 24 translations). |
| `packages_ui/editor_ui` | The window's page, `EditorBloc`, components (canvas, the Tools, Colors, History and Layers windows, menus, tool bar, tabs, status bar, previewing dialog), widgets, and the size and save dialogs. |
| `lib/` | `bootstrap` (bridge, settings, dependency injection, the window through `window_manager`), `di.dart`, `PaintboxApp` (theme, accent and language), the screenshot scenes. |

### Bridge

`paintbox_bridge` is thin: it has no logic and only converts types.
`PaintImage` is an open image and wraps `paintbox_core::Session`: the
core document with its gesture controller, the previewing dialog, the
held mouse button and the saved state. The active tool and the tool
bar's settings belong to the program, so they come with each call that
needs them. The effect that Ctrl+F repeats is shared by all images; the
session hands over the applied effect through `take_applied_effect`.

The core's plain types (`Tool`, `ToolSettings`, `Rgba8`,
`LayerProperties`, the setting enums) are mirrored with
`#[frb(mirror)]`, so Dart sees generated classes and enums rather than
JSON. Dialog parameters (sliders, check boxes, the random seed) are read
and written through the effect's serde form (`paintbox_core::params`).
Core failures become `PaintError` with the core's code; commands with
nothing to act on return `false`. A finished effect render is announced
on the `previewWakes` stream, so nothing polls every frame.

In `paint_logic`, `ImageSession` reads an image: one `takeChange` call
asks the core what changed since the last call (dirty rectangle, layers,
history, selection, command availability) and reads only that. The bloc
receives a ready `ImageChange` and does not assemble state from bridge
calls itself.

Calls that accompany a gesture or a command are synchronous, because
their order matters and each costs milliseconds of core work. Reading
and writing files and encoding the clipboard are asynchronous and run on
the bridge's worker threads. Saving writes a snapshot of the layers
(`ImageSnapshot`), so painting can continue during a save.

### Canvas

After each action (for pointer moves, once per frame: the core paints
every move, the screen takes the changes once), the bloc takes an
`ImageChange` with the 256 × 256 tiles the dirty rectangle touches. The
core composites them in one pass as premultiplied RGBA
(`Document::composite_tiles`), the format `decodeImageFromPixels` takes
as `rgba8888`. The tiles reach the canvas as a `CanvasTilesAction`: a
stream for drawing, not screen state. `CanvasTiles` turns them into
`ui.Image`s and keeps the old tile until the new one is ready (any tile
newer than the one on screen is shown), so a stroke neither flickers nor
lags.

The canvas has two `RepaintBoundary` layers: the tiles, and the marching
ants with the handles, which repaint separately. Tile edges snap to
physical pixels; magnified pixels are drawn without smoothing and
reduced ones with filtering. The checkerboard is fixed to the screen.
The marching ants are the core's selection outline, turned into a `Path`
once per change of the selection or the view and drawn with an animated
striped shader. At 100% zoom one image pixel is one physical screen
pixel, whatever the display scale.

### Look

The look is glass instead of default Material: a deep background with
two soft blooms of the accent color, translucent panels with hairline
borders, the Manrope typeface (OFL, `assets/fonts`), the `Space` and
`Radii` scales, and motion of 160–220 ms. The interface is restrained
and compact: radii are small (6 for buttons, rows and fields, 8 for
windows and menus, 10 for dialogs; the larger steps are only for pills),
the dense `ControlSize` scale sizes buttons, rows and bars, and
everything aligns to the `Space` grid.

The layout follows Paint.NET 5. The menus File to Effects are at the
top, with a row of command icons below them (files, clipboard, Crop,
Deselect, Undo and Redo, pixel grid, rulers). Next to them is the strip
of image tabs, two rows high: a thumbnail with the name below it,
shortened with "…", a dot for unsaved changes and a close button on the
thumbnail's corner. The top right corner holds the toggles of the Tools,
History, Layers and Colors windows, the settings and help; they replace
Paint.NET 5's Window and Help menus. Below is the tool bar: groups
separated by a bar, a row of icons where a picture tells the values
apart, and a drop-down list with names where there are many values or
they are not obvious (`SettingIconWidget` draws the setting glyphs). The
canvas has rulers along the top and left edges that mark the pointer.

The floating windows are Tools (top left, two columns), Colors (bottom
left), History (top right) and Layers (bottom right). Colors has two
modes: More shows the wheel with RGB, hex, HSV and opacity beside it and
the palette below; Less shows the wheel with opacity, hex and a palette
of two rows of eight below it, no wider than the wheel. Floating windows
are opaque glass with a shadow and no blur (a blur over a canvas that
repaints all the time would cost frames); they turn translucent while
the pointer is over the canvas. Tool icons are vector glyphs
(`ToolIconWidget`) colored by kind, as in Paint.NET, with separate hues
for the dark and light themes (`IconHues`). The status bar shows the
tool hint, the selection and image sizes, the pointer position, the
units and the zoom with a slider.

### Theme, accent and language

The settings menu (the gear in the top right corner) has three
submenus:

- **Theme**: dark (the default), light, or the system's. View > Theme
  offers the same choice.
- **Accent color**: blue (the default), green, amber, purple, red, gray,
  or a custom color from the color wheel. `AppTheme` derives the accent
  roles from it: the primary color, `accentSoft` for selected rows and
  buttons, the glow, sliders and the background blooms. `AccentPalette`
  moves the accent toward white on the dark theme and toward black on
  the light one until it reaches a 3:1 contrast against the surface;
  accent-colored text reaches 4.5:1, and text on the accent is black or
  white, whichever reads better. Any custom color therefore stays
  usable; `accent_palette_test.dart` checks the presets and extreme
  custom colors.
- **Language**: the system's language, or one of the 25 interface
  languages listed by their own names (`AppLanguages`). A system
  language the program lacks falls back to English.

The program remembers between launches the tool, the tool bar settings,
the JPEG quality, recent files, the visibility and position of the
windows, the Colors mode, the rulers, the theme, the accent, the
language and the last folder. Drag and drop (files onto the window, tabs,
layers, palette swatches, windows by their title) is described in
[behaviour.md](behaviour.md).

## Not done yet

The core's open items are listed under "Open items" in
[behaviour.md](behaviour.md): rotating and scaling the selection outline,
units and DPI, printing. In the program: the arrow keys do not move the
cursor outside the move tools; Ctrl+PageUp, Ctrl+PageDown and Ctrl+F4 do
not switch or close tabs; palette files cannot be loaded; new layers get
the core's English default names.
