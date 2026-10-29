# Notices

Paintbox is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version. The full text is in [LICENSE](LICENSE).

Copyright (C) 2026 the Paintbox authors.

Paintbox is written from scratch in Rust and Dart. Some of its
algorithms and much of its behaviour are ported from two MIT-licensed
programs, and it ships a font and third-party libraries under their own
permissive licenses. Each is listed below with what Paintbox takes from
it. The MIT, BSD, Apache 2.0, Zlib and Unicode licenses of the code are
compatible with the GPL version 3: the combined program is distributed
under the GPL, and the notices below stay with it. The font is not part
of the program's code: it is distributed alongside it, unmodified, under
its own SIL Open Font License 1.1, which allows bundling and embedding
it with software under any license.

"Paint.NET" is a trademark of its owner. Paintbox is not affiliated with
or endorsed by Paint.NET or Pinta, and does not use their names for
itself.

## Paint.NET 3.36.7

Source: the last open-source release of Paint.NET, published as OpenPDN
(<https://github.com/rivy/OpenPDN>). License: MIT, with three exceptions
quoted in full in [LICENSES/Paint.NET-3.36.7.txt](LICENSES/Paint.NET-3.36.7.txt).

Ported into `crates/paintbox_core` (rewritten in Rust; no source file is
copied):

- **Blend modes**: the 14 layer blend formulas of `UserBlendOps`
  (Normal, Multiply, Additive, Color Burn, Color Dodge, Reflect, Glow,
  Overlay, Difference, Negation, Lighten, Darken, Screen, Xor) with the
  same integer rounding.
- **Adjustments**: Auto-Level, Black and White, Brightness / Contrast,
  Curves, Hue / Saturation, Invert Colors, Levels, Posterize, Sepia
  (`UnaryPixelOps` and the adjustment effects).
- **Effects** (31): Ink Sketch, Oil Painting, Pencil Sketch; Fragment,
  Gaussian Blur, Motion Blur, Radial Blur, Surface Blur, Unfocus, Zoom
  Blur; Bulge, Dents, Frosted Glass, Pixelate, Polar Inversion, Tile
  Reflection, Twist; Add Noise, Median, Reduce Noise; Glow, Red Eye
  Removal, Sharpen, Soften Portrait; Clouds, Julia Fractal, Mandelbrot
  Fractal; Edge Detect, Emboss, Outline, Relief.
- **Tools and behaviour**: the behaviour of the selection, painting,
  shape, fill, gradient, text, clone stamp and recolor tools and their
  modifier keys; selection combine modes; menu keyboard shortcuts;
  history and layer commands. `docs/behaviour.md` records each choice.

Not used: the Paint.NET logo and icon artwork, its "resource assets"
(`.resx` and `.png` resources: icons, menu and status bar texts) and the
General Polygon Clipper; all three are outside the MIT grant. Paintbox's
icons are drawn anew. The names of commands, tools and effects follow
Paint.NET's; the hints, messages and dialog texts are written anew.

```
Paint.NET
Copyright (C) dotPDN LLC, Rick Brewster, Chris Crosetto, Tom Jackson,
Michael Kelsey, Brandon Ortiz, Craig Taylor, Chris Trevino, and Luke
Walker.
Portions Copyright (C) Microsoft Corporation. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## Pinta

Source: <https://github.com/PintaProject/Pinta>. License: MIT,
[LICENSES/Pinta-MIT.txt](LICENSES/Pinta-MIT.txt).

Used as the second reference: to check the ported effect and adjustment
algorithms against a maintained implementation (percentiles, warp
effects, the effects list) and, for the Ukrainian interface, as a
reference for established terms. No source file is copied.

```
The MIT License

Copyright (c) 2010 Jonathan Pobst <monkey@jpobst.com>

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## Manrope font

The interface typeface (`app/assets/fonts`) and the built-in font of the
Text tool, embedded in the core (`crates/paintbox_core/assets/fonts`).
Copyright 2018 The Manrope Project Authors
(<https://github.com/sharanda/manrope>). License: SIL Open Font License
1.1, [LICENSES/OFL-1.1-Manrope.txt](LICENSES/OFL-1.1-Manrope.txt) (also
next to each copy of the font). The font is bundled unmodified and is
not sold by itself. The Text tool can also use fonts installed on the
user's system; those stay under their own licenses and are not shipped.

## Cargokit

The build glue that compiles the Rust core during the Flutter build
(`app/packages_tools/paint_bridge/cargokit`), copied from Cargokit as
flutter_rust_bridge recommends. Copyright 2022 Matej Knopp. License: MIT
or Apache 2.0, [LICENSES/Cargokit.txt](LICENSES/Cargokit.txt).

## Libraries

Rust crates and Dart packages the program links, with their licenses:
[docs/third-party.md](docs/third-party.md). The full license texts and
copyright lines travel inside the program and are shown by Help >
Licenses: Flutter collects those of the Dart packages, and
`app/assets/licenses/rust-crates.txt` (written by
`tools/make-notices.ps1`) holds those of the Rust crates.
