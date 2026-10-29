# Contributing to Paintbox

Fixes, translations, new effects and tools are welcome. This page lists
where things live and the rules the code follows; please read it before
a larger change.

By submitting a change you agree that it is distributed under the
project's license, the GNU GPL version 3 or later ([LICENSE](LICENSE)).

## Where to look

| Question | Read |
|---|---|
| How is the repository laid out, and what is in each package? | [docs/architecture.md](docs/architecture.md) |
| How do I build, run, check, screenshot and package it? | [docs/building.md](docs/building.md) |
| What does a tool, key or menu item do, and why? | [docs/behaviour.md](docs/behaviour.md) |
| Which word does the interface use for a term? | [docs/glossary.md](docs/glossary.md) |
| What is ported from Paint.NET and Pinta, under which license? | [NOTICE.md](NOTICE.md) |
| Which libraries ship with the program? | [docs/third-party.md](docs/third-party.md) |

Useful starting points in the code:

- `crates/paintbox_core/src/lib.rs` explains how a front end drives the
  core; `session.rs` is the per-image entry point, `command.rs` lists
  every menu command with its keys, and `tool.rs` every tool with its
  settings.
- `app/packages_tools/paint_bridge/rust/src/api` is the whole bridge API
  the Flutter program sees.
- `app/packages_ui/editor_ui/lib/src/bloc` holds the editor's single bloc:
  `editor_event.dart` lists every user action, `editor_state.dart` every
  screen state.
- `app/packages_ui/app_ui/lib/src/localization/arb` holds the interface
  texts; `app_en.arb` is the template.

## Layers and boundaries

The program is a melos monorepo of packages in three layers,
**tools ← logic ← ui**, with `app/lib/` as the composition root. A layer
imports only from the layers to its left.

- `packages_tools/` holds mechanisms without features. `core` has
  `Failure`, `AppLog`, `injector` and `EventBusService`; `paint_bridge`
  exposes the Rust core through flutter_rust_bridge (generated bindings
  and Cargokit).
- `packages_logic/paint_logic` holds the open images, settings, recent
  files, clipboard, file dialogs and canvas view. Nothing in logic reads
  `injector`; dependencies come through constructors.
- `packages_ui/` holds `app_ui` (theme, tokens, glass surfaces, toasts,
  dialogs, `ActionListener`, gen-l10n) and `editor_ui` (page, components,
  widgets, bloc).
- Logic that does not depend on the UI toolkit lives in the Rust core:
  tools, gestures, commands with their availability and keys, previewing
  dialogs, key cycles. Dart does not repeat it; the bridge only
  translates. New logic of that kind goes into `paintbox_core` first and
  then into the bridge.
- The bridge (`packages_tools/paint_bridge/rust`) stays thin: it converts
  types, turns core failures into `PaintError`, and never lets a panic
  cross the boundary. After changing `rust/src/api`, run
  `melos run gen:bridge`.
- The core depends on no UI toolkit, so it can be embedded in another
  front end.

## Failures

- Only `Failure` (sealed, in `core`) is thrown and caught. A core failure
  becomes `PaintFailure` (with the core's stable code) or `StorageFailure`
  in one place, `PaintCall`. Every core call from logic goes through
  `PaintCall.run` or `runAsync`.
- Every bloc handles the failure branch with `AppLog.failure` plus a
  `ShowFailureAction` on the event bus. A failure swallowed silently is a
  bug.

## Screen state

- A bloc is the screen's state machine with one entry point,
  `add(event)`. States are sealed and immutable, with `copyWith`, and
  have one subclass per mutually exclusive situation. Conditions the
  screen checks are getters on the state (`canRun`, `canUndo`), not
  calculations in widgets.
- Every user action is an `XEvent`. One-off consequences (questions,
  toasts, changed canvas tiles) are `XAction`s on `EventBusService`,
  which `ActionListener` receives; they are not flags in states.
- A page (`Page`) does dependency injection through `injector` and owns
  the lifecycle. A component (`Component`) holds `BlocBuilder` or
  `BlocSelector` and `ActionListener`. A widget (`Widget`) knows no
  bloc: everything it shows is passed in, and everything it does is a
  callback.

## Types and names

- Analysis is strict (`strict-casts`, `strict-inference`,
  `strict-raw-types`). Use nullable types only where absence is a value.
  There are no global functions or variables (use static members or
  extensions); the exceptions are `main`, `bootstrap`,
  `configureDependencies` and `injector`.
- Suffixes are required: Page, Component, Widget, Bloc, Event, State,
  Action, Repository, Service, Storage, JsonMapper. One class per file,
  and the file is named after the class (small private widgets may sit
  next to their owner). Flutter names follow Flutter's conventions.
- `context` always means a `BuildContext`. A comment says why, not what.

## Interface

- The look is glass instead of default Material: surfaces use
  `GlassPanel`, borders use `Hairline` and the tokens, rows use
  `GlassTap`. There is one typeface (Manrope), spacing comes only from
  the `Space` scale, corner radii from `Radii`, and motion takes
  160–220 ms (`Motion`). Colors come from `AppTokens` and the color
  scheme, never from constants such as `Colors.red`. Every surface must
  work in the dark and the light theme and with any accent color.
- The program looks the same on every platform: the layout is its own,
  and only the window and its title bar are the system's.
- Nothing jumps in size: whatever grows is animated (`AnimatedSize`).
- Consequences are toasts (`AppToastService`), questions use
  `AppDialogs`, and form errors appear next to the field.
- Every word of the interface comes from gen-l10n in `app_ui`
  (`melos run gen:l10n`). English (`app_en.arb`) is the template; a new
  key goes into every arb file, and the test `arb_completeness_test.dart`
  fails until it does. Words for the core's identifiers (commands,
  tools, parameters) go through `PaintWords`, which falls back to the
  core's English name.

## Checks

- `tools/check.ps1` runs everything: `cargo fmt`, `cargo clippy`,
  `cargo test`, the bridge build the Flutter tests load,
  `dart analyze --fatal-infos` (must be clean), the format check and the
  Flutter tests. `-Build` adds `flutter build windows --release`.
- Check a visual change with screenshots: `paintbox --screenshot=<png>`
  (scenes and options are in [docs/building.md](docs/building.md)), in
  both themes.
- Commit messages are in English and describe the change and its reason.
