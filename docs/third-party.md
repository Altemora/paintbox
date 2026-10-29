# Third-party libraries

These are the libraries built into the program, with their licenses.
Tools used only for development (tests, linters, melos, code generators)
are not listed. Every license below (MIT, BSD, Apache 2.0, Zlib,
Unicode, 0BSD or Unlicense) is permissive and compatible with the GNU
GPL version 3, under which Paintbox is distributed. Where a crate offers
a choice ("A OR B"), Paintbox uses the GPL-compatible option (MIT or
Apache 2.0). The ported algorithms, the font and Cargokit are covered in
[NOTICE.md](../NOTICE.md).

The lists come from these commands; regenerate them after changing
dependencies:

```
cargo tree -p paintbox_bridge -e normal --prefix none -f "{p}|{l}" --target all
cd app && flutter pub deps --json
```

The license of each Dart package is taken from the package's `LICENSE`
file in the pub cache. The Flutter SDK (`flutter`,
`flutter_localizations`, `sky_engine`) is BSD-3-Clause; the Flutter
engine contains third-party code under its own licenses, which Flutter
collects into the program's built-in license list.

## Rust (core and bridge)

| Crate | Version | License |
|---|---|---|
| ab_glyph | 0.2.32 | Apache-2.0 |
| ab_glyph_rasterizer | 0.1.10 | Apache-2.0 |
| addr2line | 0.27.1 | Apache-2.0 OR MIT |
| adler2 | 2.0.1 | 0BSD OR MIT OR Apache-2.0 |
| aho-corasick | 1.1.5 | Unlicense OR MIT |
| allo-isolate | 0.1.27 | Apache-2.0 |
| android_log-sys | 0.3.2 | MIT OR Apache-2.0 |
| android_logger | 0.15.1 | MIT OR Apache-2.0 |
| anyhow | 1.0.104 | MIT OR Apache-2.0 |
| atomic | 0.5.3 | Apache-2.0 OR MIT |
| backtrace | 0.3.77 | MIT OR Apache-2.0 |
| bitflags | 2.13.2 | MIT OR Apache-2.0 |
| block-buffer | 0.10.4 | MIT OR Apache-2.0 |
| bumpalo | 3.20.3 | MIT OR Apache-2.0 |
| bytemuck | 1.25.2 | Zlib OR Apache-2.0 OR MIT |
| byteorder | 1.5.0 | Unlicense OR MIT |
| byteorder-lite | 0.1.0 | Unlicense OR MIT |
| cfg-if | 1.0.5 | MIT OR Apache-2.0 |
| console_error_panic_hook | 0.1.7 | Apache-2.0 OR MIT |
| crc32fast | 1.5.3 | MIT OR Apache-2.0 |
| crypto-common | 0.1.7 | MIT OR Apache-2.0 |
| dart-sys | 4.1.5 | MIT OR Apache-2.0 |
| dashmap | 5.5.3 | MIT |
| delegate-attr | 0.3.1 | MIT |
| digest | 0.10.7 | MIT OR Apache-2.0 |
| env_filter | 0.1.4 | MIT OR Apache-2.0 |
| equivalent | 1.0.3 | Apache-2.0 OR MIT |
| fdeflate | 0.3.7 | MIT OR Apache-2.0 |
| flate2 | 1.1.10 | MIT OR Apache-2.0 |
| flutter_rust_bridge | 2.13.0 | MIT |
| flutter_rust_bridge_macros | 2.13.0 | MIT |
| futures | 0.3.34 | MIT OR Apache-2.0 |
| futures-channel | 0.3.34 | MIT OR Apache-2.0 |
| futures-core | 0.3.34 | MIT OR Apache-2.0 |
| futures-executor | 0.3.34 | MIT OR Apache-2.0 |
| futures-io | 0.3.34 | MIT OR Apache-2.0 |
| futures-macro | 0.3.34 | MIT OR Apache-2.0 |
| futures-sink | 0.3.34 | MIT OR Apache-2.0 |
| futures-task | 0.3.34 | MIT OR Apache-2.0 |
| futures-util | 0.3.34 | MIT OR Apache-2.0 |
| generic-array | 0.14.7 | MIT |
| getrandom | 0.4.3 | MIT OR Apache-2.0 |
| gimli | 0.34.0 | MIT OR Apache-2.0 |
| hashbrown | 0.14.5 | MIT OR Apache-2.0 |
| hashbrown | 0.17.1 | MIT OR Apache-2.0 |
| hermit-abi | 0.5.3 | MIT OR Apache-2.0 |
| hex | 0.4.3 | MIT OR Apache-2.0 |
| image | 0.25.10 | MIT OR Apache-2.0 |
| image-webp | 0.2.4 | MIT OR Apache-2.0 |
| indexmap | 2.14.2 | Apache-2.0 OR MIT |
| itoa | 1.0.18 | MIT OR Apache-2.0 |
| js-sys | 0.3.106 | MIT OR Apache-2.0 |
| lazy_static | 1.5.1 | MIT OR Apache-2.0 |
| libc | 0.2.191 | MIT OR Apache-2.0 |
| lock_api | 0.4.14 | MIT OR Apache-2.0 |
| log | 0.4.34 | MIT OR Apache-2.0 |
| md-5 | 0.10.6 | MIT OR Apache-2.0 |
| memchr | 2.8.3 | Unlicense OR MIT |
| miniz_oxide | 0.8.9 | MIT OR Zlib OR Apache-2.0 |
| miniz_oxide | 0.9.1 | MIT OR Zlib OR Apache-2.0 |
| moxcms | 0.8.1 | BSD-3-Clause OR Apache-2.0 |
| nix | 0.31.3 | MIT |
| num-traits | 0.2.19 | MIT OR Apache-2.0 |
| num_cpus | 1.17.0 | MIT OR Apache-2.0 |
| object | 0.40.0 | Apache-2.0 OR MIT |
| once_cell | 1.21.4 | MIT OR Apache-2.0 |
| oslog | 0.2.0 | MIT |
| owned_ttf_parser | 0.25.1 | Apache-2.0 |
| parking_lot_core | 0.9.12 | MIT OR Apache-2.0 |
| pin-project-lite | 0.2.17 | Apache-2.0 OR MIT |
| png | 0.18.1 | MIT OR Apache-2.0 |
| portable-atomic | 1.15.0 | Apache-2.0 OR MIT |
| proc-macro2 | 1.0.107 | MIT OR Apache-2.0 |
| pxfm | 0.1.30 | BSD-3-Clause OR Apache-2.0 |
| quick-error | 2.0.1 | MIT OR Apache-2.0 |
| quote | 1.0.47 | MIT OR Apache-2.0 |
| r-efi | 6.0.0 | MIT OR Apache-2.0 OR LGPL-2.1-or-later |
| redox_syscall | 0.5.18 | MIT |
| regex | 1.13.1 | MIT OR Apache-2.0 |
| regex-automata | 0.4.18 | MIT OR Apache-2.0 |
| regex-syntax | 0.8.11 | MIT OR Apache-2.0 |
| rustc-demangle | 0.1.28 | MIT OR Apache-2.0 |
| scopeguard | 1.2.0 | MIT OR Apache-2.0 |
| serde | 1.0.229 | MIT OR Apache-2.0 |
| serde_core | 1.0.229 | MIT OR Apache-2.0 |
| serde_derive | 1.0.229 | MIT OR Apache-2.0 |
| serde_json | 1.0.154 | MIT OR Apache-2.0 |
| simd-adler32 | 0.3.10 | MIT |
| slab | 0.4.12 | MIT |
| smallvec | 1.16.4 | MIT OR Apache-2.0 |
| syn | 2.0.119 | MIT OR Apache-2.0 |
| syn | 3.0.9 | MIT OR Apache-2.0 |
| thiserror | 2.0.21 | MIT OR Apache-2.0 |
| thiserror-impl | 2.0.21 | MIT OR Apache-2.0 |
| threadpool | 1.8.1 | MIT OR Apache-2.0 |
| tokio | 1.54.1 | MIT |
| ttf-parser | 0.25.1 | MIT OR Apache-2.0 |
| typed-path | 0.13.0 | MIT OR Apache-2.0 |
| typenum | 1.20.1 | MIT OR Apache-2.0 |
| unicode-ident | 1.0.27 | (MIT OR Apache-2.0) AND Unicode-3.0 |
| wasm-bindgen | 0.2.129 | MIT OR Apache-2.0 |
| wasm-bindgen-futures | 0.4.79 | MIT OR Apache-2.0 |
| wasm-bindgen-macro | 0.2.129 | MIT OR Apache-2.0 |
| wasm-bindgen-macro-support | 0.2.129 | MIT OR Apache-2.0 |
| wasm-bindgen-shared | 0.2.129 | MIT OR Apache-2.0 |
| web-sys | 0.3.106 | MIT OR Apache-2.0 |
| windows-link | 0.2.1 | MIT OR Apache-2.0 |
| windows-sys | 0.61.2 | MIT OR Apache-2.0 |
| zip | 9.1.3 | MIT |
| zlib-rs | 0.6.8 | Zlib |
| zmij | 1.0.23 | MIT |
| zopfli | 0.8.4 | Apache-2.0 |
| zune-core | 0.5.3 | MIT OR Apache-2.0 OR Zlib |
| zune-jpeg | 0.5.15 | MIT OR Apache-2.0 OR Zlib |

## Dart and Flutter (program)

| Package | Version | License |
|---|---|---|
| args | 2.7.0 | BSD-3-Clause |
| async | 2.13.1 | BSD-3-Clause |
| bloc | 9.2.1 | MIT |
| build_cli_annotations | 2.1.1 | MIT |
| characters | 1.4.1 | BSD-3-Clause |
| clock | 1.1.3 | Apache-2.0 |
| code_assets | 1.2.1 | BSD-3-Clause |
| collection | 1.19.1 | BSD-3-Clause |
| cross_file | 0.3.5+5 | BSD-3-Clause |
| crypto | 3.0.8 | BSD-3-Clause |
| desktop_drop | 0.7.1 | Apache-2.0 |
| equatable | 2.1.0 | MIT |
| ffi | 2.2.0 | BSD-3-Clause |
| file_selector_android | 0.5.2+11 | Apache-2.0 |
| file_selector_ios | 0.5.3+7 | BSD-3-Clause |
| file_selector_linux | 0.9.4+1 | BSD-3-Clause |
| file_selector_macos | 0.9.5+2 | BSD-3-Clause |
| file_selector_platform_interface | 2.7.0 | BSD-3-Clause |
| file_selector_web | 0.9.5 | BSD-3-Clause |
| file_selector_windows | 0.9.3+6 | BSD-3-Clause |
| file_selector | 1.1.0 | BSD-3-Clause |
| fixnum | 1.1.1 | BSD-3-Clause |
| flutter_bloc | 9.1.1 | MIT |
| flutter_rust_bridge | 2.13.0 | MIT |
| get_it | 9.3.0 | MIT |
| hooks | 2.0.2 | BSD-3-Clause |
| http_parser | 4.1.2 | BSD-3-Clause |
| http | 1.6.0 | BSD-3-Clause |
| intl | 0.20.3 | BSD-3-Clause |
| jni_flutter | 1.0.4+1 | BSD-3-Clause |
| jni_util | 1.0.0 | BSD-3-Clause |
| jni | 1.1.1 | BSD-3-Clause |
| json_annotation | 4.12.0 | BSD-3-Clause |
| logging | 1.3.0 | BSD-3-Clause |
| material_color_utilities | 0.13.0 | Apache-2.0 |
| meta | 1.18.3 | BSD-3-Clause |
| nested | 1.0.0 | MIT |
| objective_c | 9.5.0 | BSD-3-Clause |
| package_config | 2.2.0 | BSD-3-Clause |
| pasteboard | 0.5.0 | Apache-2.0 |
| path_provider_android | 2.3.1 | BSD-3-Clause |
| path_provider_foundation | 2.6.0 | BSD-3-Clause |
| path_provider_linux | 2.2.2 | BSD-3-Clause |
| path_provider_platform_interface | 2.1.3 | BSD-3-Clause |
| path_provider_windows | 2.3.0 | BSD-3-Clause |
| path_provider | 2.1.6 | BSD-3-Clause |
| path | 1.9.1 | BSD-3-Clause |
| platform | 3.2.0 | BSD-3-Clause |
| plugin_platform_interface | 2.1.8 | BSD-3-Clause |
| provider | 6.1.5+1 | MIT |
| pub_semver | 2.2.1 | BSD-3-Clause |
| record_use | 0.6.0 | BSD-3-Clause |
| screen_retriever_linux | 0.2.2 | MIT |
| screen_retriever_macos | 0.2.2 | MIT |
| screen_retriever_platform_interface | 0.2.2 | MIT |
| screen_retriever_windows | 0.2.2 | MIT |
| screen_retriever | 0.2.2 | MIT |
| source_span | 1.10.2 | BSD-3-Clause |
| string_scanner | 1.4.1 | BSD-3-Clause |
| term_glyph | 1.2.2 | BSD-3-Clause |
| typed_data | 1.4.0 | BSD-3-Clause |
| universal_platform | 1.1.0 | MIT |
| uuid | 4.6.0 | MIT |
| vector_math | 2.4.0 | BSD-3-Clause |
| web | 1.1.2 | BSD-3-Clause |
| window_manager | 0.5.2 | MIT |
| xdg_directories | 1.1.0 | BSD-3-Clause |
| yaml | 3.1.4 | MIT |
