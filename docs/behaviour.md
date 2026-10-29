# Paintbox: editor behaviour

This document describes the behaviour that the core reproduces and the
program shows. The core code is the source of truth; this page explains
how each part works and why it was built that way.

Paintbox is a cross-platform raster image editor in the spirit of
Paint.NET 3.x, with layers and the same tools, keyboard shortcuts and
behaviour. The core (`crates/paintbox_core`) has no user interface; the
front end is a Flutter program (`app/`). See
[architecture.md](architecture.md) for how the parts fit together,
[building.md](building.md) for building, and
[../CONTRIBUTING.md](../CONTRIBUTING.md) for contributing.

## Sources

- **OpenPDN** ([github.com/rivy/OpenPDN](https://github.com/rivy/OpenPDN))
  is the source code of Paint.NET 3.36.7, released under the MIT
  license. It is the primary reference for blend formulas, adjustment
  and effect algorithms, tool modifiers and menu shortcuts.
- **Pinta** ([github.com/PintaProject/Pinta](https://github.com/PintaProject/Pinta))
  is an actively maintained Paint.NET clone written in C# with GTK,
  also under MIT. It is a secondary reference for checking algorithms
  and the list of effects, and its Ukrainian localization serves as a
  terminology reference.

Both licenses and the list of what was carried over are in
[NOTICE.md](../NOTICE.md).

Paintbox does not take Paint.NET's icons and cursors (they are not
under MIT), the General Polygon Clipper library (not under MIT, and not
needed because our selection is a mask), or the name "Paint.NET" (a
trademark). The code of both projects is only read as a reference; none
of their files are part of the build.

## Document model

A document consists of a fixed-size canvas, a stack of raster layers,
an active layer, a selection, the two user colors and a history. A new
document in Paint.NET is 800 × 600 with a single layer named
"Background" filled with white; a new layer is transparent.

| Part | What it holds |
|---|---|
| Layer | RGBA8 pixels the size of the canvas, a name, visibility, opacity 0–255 and a blend mode. |
| Stack | The bottom layer has index 0. The Layers window lists layers from top to bottom. |
| Active layer | The layer that tools paint on and that adjustments and effects apply to. |
| Selection | A coverage mask with a value of 0–255 for each canvas pixel, plus a flag that says whether a selection exists. With no selection, tools, adjustments and effects act on the whole layer, and the Copy, Cut, Erase, Fill, Invert and Deselect commands are disabled. |
| Colors | The primary color (black by default) and the secondary color (white by default), both RGBA. |
| History | The steps of past actions, with Undo and Redo. |

### Pixel format

Pixels are stored as **straight RGBA8** (color not premultiplied by
alpha), like `ColorBgra` in Paint.NET. The reasons are:

- Paint.NET's blend mode formulas are written for straight alpha;
  ported literally, they give the same result to within one unit.
- Adjustments (Levels, Curves, Hue / Saturation) work with the pixel's
  color without dividing by alpha, as in the source.
- PNG and ORA store straight alpha, so reading and writing need no
  conversion and lose no precision in semi-transparent pixels.

The cost is a division by the combined alpha during blending, which the
core does in integer arithmetic. Blurs that average neighbouring pixels
weight color by alpha (like `ColorBgra.Blend` in the source) so that
transparent pixels do not darken edges.

## Layers

### Properties

| Property | Range | Behaviour |
|---|---|---|
| Name | string | A new layer is named "Layer N", where N is the number of layers + 1, so names can repeat. The first layer is named "Background". A duplicate keeps the name of the original. |
| Visible | yes/no | A hidden layer takes no part in compositing or in flat saving. Hiding the active layer makes the nearest visible layer active. |
| Background | yes/no | Marks the Background layer (shown in italics in the Layers window). Canvas Size fills new area of such a layer with the secondary color instead of transparency. Duplicating and importing clear the flag. |
| Opacity | 0–255 | Multiplies the alpha of the layer's pixels before blending. |
| Blend mode | 14 modes | See below. |

The Layer Properties dialog (F4, or double-click a layer) shows changes
live and records a single history step on OK. The visibility check box
in the Layers window also records a step.

### Layer commands

| Command | Key | Behaviour |
|---|---|---|
| Add New Layer | Ctrl+Shift+N | Adds a transparent layer above the active one and makes it active. |
| Delete Layer | Ctrl+Shift+Delete | Deletes the active layer; the last remaining layer cannot be deleted. |
| Duplicate Layer | Ctrl+Shift+D | Adds a copy above the active layer with the same properties. |
| Merge Layer Down | Ctrl+M | Blends the active layer onto the layer below using the active layer's blend mode and opacity; the result is the lower layer, which keeps its own properties. |
| Import From File | — | The image from a file becomes a new layer named after the file, placed at the top-left corner. If the image is larger than the canvas, the program offers to enlarge the canvas. |
| Flip Horizontal / Vertical | — | Mirrors the active layer. |
| Rotate / Zoom | — | Rotates, scales and offsets the layer (deferred; see "Open items"). |
| Move Layer Up / Down | window buttons | Swaps the layer with its neighbour. |
| Layer Properties | F4 | Opens the properties dialog. |

### Compositing and blend modes

Compositing runs from the bottom up: the result starts transparent, and
each visible layer is blended onto it with its own blend mode. The
front end draws a checkerboard under the result.

Notation: `B` is the lower (accumulated) pixel, `S` is the layer pixel,
channels are 0–255, and `a_S = S.a · opacity / 255`. Paint.NET's
general formula (`UserBlendOps.Generated.H.cs`, the `BLEND` macro) for
each color channel is:

```
y = a_B · (255 − a_S) / 255        share where only the lower pixel shows
x = a_B · a_S / 255                share where both are blended
z = a_S − x                        share where only the layer shows
a = y + a_S                        alpha of the result
c = (B.c · y + S.c · z + F(B.c, S.c) · x) / a      (a = 0 → transparent)
```

The product `p · q / 255` is `INT_SCALE`:
`((p·q + 128) >> 8 + p·q + 128) >> 8`. The blend function `F(A, B)`,
where `A` is the lower pixel and `B` is the layer pixel, is:

| Mode | `F(A, B)` |
|---|---|
| Normal | `B` |
| Multiply | `A · B / 255` |
| Additive | `min(255, A + B)` |
| Color Burn | `B = 0 → 0`, otherwise `max(0, 255 − (255 − A) · 255 / B)` |
| Color Dodge | `B = 255 → 255`, otherwise `min(255, A · 255 / (255 − B))` |
| Reflect | `B = 255 → 255`, otherwise `min(255, A² / (255 − B))` |
| Glow | Reflect with the arguments swapped: `F(B, A)` |
| Overlay | `A < 128 → 2A · B / 255`, otherwise `255 − 2(255 − A)(255 − B) / 255` |
| Difference | `|B − A|` |
| Negation | `255 − |255 − A − B|` |
| Lighten | `max(A, B)` |
| Darken | `min(A, B)` |
| Screen | `A + B − A · B / 255` |
| Xor | `A xor B` (bitwise) |

The divisions in Color Burn, Color Dodge and Reflect are integer
divisions. The source performs them through a table of magic
multipliers (`masTable`); the result is the same.

### Dirty rectangles

Every change to pixels, visibility, opacity, blend mode or layer order
adds a rectangle to the document's dirty region. The front end takes
it (`take_dirty`) and recomposites only that rectangle, so a brush
stroke on a 4096 × 4096 canvas recomposites a few thousand pixels
rather than 16 million.

## Selection

### Selection tools

| Tool | Key | Behaviour |
|---|---|---|
| Rectangle Select | S | Dragging draws a rectangle; Shift constrains it to a square. Draw modes: Normal, Fixed Ratio (drag with a set aspect ratio) and Fixed Size (a click places a rectangle of a set size). |
| Lasso Select | S | Dragging draws a freeform outline, closed with a straight line. |
| Ellipse Select | S | Dragging draws an ellipse inscribed in the dragged box; Shift constrains it to a circle. |
| Magic Wand | S | Clicking selects the region of color under the cursor, using Tolerance and Flood Mode; Shift switches the mode (contiguous ↔ global). |

Pressing S again within 2 seconds switches to the next tool that shares
the key, and Shift+S switches to the previous one. After a pause, S
starts again from the first tool (Rectangle Select) and Shift+S from the
last (Magic Wand). M and O work the same way. Tool keys have no effect
while a mouse button is held down.

Dragging a selection works as follows:

- A click without movement clears the selection in Replace mode
  (recording a "Deselect" step if there was a selection) and does
  nothing in the combining modes. A drag shorter than 50 ms counts as a
  click, but only in Replace mode.
- Pressing the other mouse button during a drag moves the whole shape.
- The mode (Ctrl or Alt with the left or right button) is taken at the
  moment the button is pressed and does not change until the drag ends.
  Shift acts live (square, circle).
- The shape is clipped to the canvas. A shape entirely outside the
  canvas clears the selection in Replace mode and does nothing in the
  combining modes.
- The mode button on the tool strip cycles Replace → Union → Exclude →
  Intersect → Xor.

Fixed Ratio keeps the first point fixed and uses the shorter side.
Fixed Size places a rectangle of the given size in document units,
which requires units and DPI (see "Open items").

Selection tools produce a hard edge: a pixel is selected if its center
lies inside the shape, as with Paint.NET's clipping region.

### Combine modes

A new selection is combined with the existing one according to the
mode set on the tool strip (Selection Mode) or a modifier held during
the drag:

| Mode | Modifier | Mask `m` from existing `p` and new `n` |
|---|---|---|
| Replace | — | `n` |
| Union (Add) | Ctrl + left | `max(p, n)` |
| Exclude (Subtract) | Alt + left | `p · (255 − n) / 255` |
| Xor | Ctrl + right | `|p − n|` |
| Intersect | Alt + right | `min(p, n)` |

Paint.NET stores a selection as a set of polygons and combines them
with the GPC library. Paintbox stores the selection as a coverage mask,
so the combine operations become the per-pixel formulas above, the edge
can be antialiased, and GPC is not needed.

### Selection commands

| Command | Key | Behaviour |
|---|---|---|
| Select All | Ctrl+A | Sets the mask to 255 over the whole canvas. |
| Deselect | Ctrl+D; Esc or Enter when there is a selection and no mouse button is held | Removes the selection. |
| Invert Selection | Ctrl+I | Sets the mask to `255 − m`; has no effect without a selection. |
| Erase Selection | Delete | Sets the active layer's pixels under the mask to `(255, 255, 255, 0)` and clears the selection, in one step. |
| Fill Selection | Backspace | Replaces the pixels under the mask with the primary color (no blending). |
| Crop to Selection | Ctrl+Shift+X | Crops all layers to the selection's bounding box. For a non-rectangular selection, pixels outside the shape become `(255, 255, 255, 0)`. The selection is cleared. |

Every change to the selection is a history step. Apart from Select All,
the commands in this table have no effect without a selection.

### Moving

| Tool | Key | Behaviour |
|---|---|---|
| Move Selected Pixels | M | A left drag lifts the selected pixels of the active layer and moves them; the vacated area is filled with the secondary color at alpha 0. Holding Ctrl when the drag starts copies instead of cutting. While moving, the fragment is drawn with nearest-neighbour sampling; resampling (Resampling, Bilinear by default) happens only when the move is finished. A right drag rotates around the center (Shift snaps to 15° steps); dragging a handle scales (Shift keeps the proportions). The arrow keys nudge by 1 pixel and Ctrl+arrow keys by 10 (not during a drag). Switching tools finishes the move; Enter and Esc finish it and clear the selection. With no selection, the whole canvas is selected first (as a separate "Select All" step). |
| Move Selection | M | Moves only the selection outline; pixels do not change (for rotating and scaling the outline, see "Open items"). |

A lifted fragment is a floating piece above the active layer; finishing
pastes it back with Normal blending. The whole drag, from lifting to
finishing, is a single history step ("Move Selected Pixels").

## Tools

Unless stated otherwise, the left mouse button paints with the primary
color and the right button with the secondary color. All painting is
clipped to the selection. Tools are listed in the order of the Tools
window.

| Tool | Key | Tool strip settings | Behaviour |
|---|---|---|---|
| Rectangle Select | S | Selection Mode, Draw Mode | See "Selection". |
| Move Selected Pixels | M | Resampling | See "Moving". |
| Lasso Select | S | Selection Mode | See "Selection". |
| Move Selection | M | — | See "Moving". |
| Ellipse Select | S | Selection Mode | See "Selection". |
| Zoom | Z | — | A left click zooms in and a right click zooms out, both centering on the clicked point. A left drag draws a zoom rectangle, which appears once the pointer has moved 10 screen pixels and is clipped to the image; releasing zooms in to it. A rectangle whose diagonal is under 10 image pixels counts as a click. Pressing the other button during the drag moves the rectangle. The right button always zooms out. The middle button pans. |
| Magic Wand | S | Selection Mode, Flood Mode, Tolerance | See "Selection". The sample is taken from the active layer. |
| Pan | H | — | Dragging moves the view. Holding Space in any tool while no mouse button is pressed switches to Pan temporarily: Space + left drag moves the view, and Space + right button scrolls continuously toward the cursor (see "Decisions"). |
| Paint Bucket | F | Flood Mode, Tolerance, Antialiasing, Alpha Blending | A click fills the region of the active layer's color under the cursor; Shift switches between contiguous and global. A click outside the selection does nothing. |
| Gradient | G | Type, Color/Transparency, Alpha Blending | Drag from the start point to the end point; Shift snaps the angle to 15° steps. The left button runs from primary to secondary, the right button the other way round. A click without dragging also paints: the whole area gets the end value. After release, the gradient stays live with two handles: dragging a handle changes it (Shift acts live), right-clicking a handle swaps the colors, pressing the other button during a drag moves both handles, and changing the colors redraws it. A click elsewhere finishes it and starts a new one; Enter finishes and Esc cancels. Defaults are Linear and Color. |
| Paintbrush | B | Width, Antialiasing, Alpha Blending, Hardness | Paints a stroke with a round brush. |
| Eraser | E | Width, Antialiasing, Hardness | A stroke lowers the alpha of pixels; its strength is the alpha of the primary color (left button) or the secondary color (right button). Pixel color does not change, and Alpha Blending has no effect. |
| Pencil | P | Alpha Blending | Paints a 1-pixel-wide stroke without antialiasing. |
| Color Picker | K | After click: do not switch (default) / previous tool / Pencil | Pressing the left button copies the full RGBA of the active layer's pixel into the primary color; the right button copies it into the secondary color. |
| Clone Stamp | L | Width, Antialiasing | Left button only. Ctrl+click sets the source point (and the source layer). Dragging copies pixels from the source. The source point moves with the cursor and is remembered between strokes, so the next stroke continues from where the previous one stopped. Opacity is `(primary.a / 255)⁴`. Deleting the source layer resets the source. |
| Recolor | R | Width, Antialiasing, Tolerance | A left drag shifts pixels close to the secondary color toward the primary color (`c + (primary − secondary)`), keeping alpha; a right drag does the reverse. Closeness is `⌈√((ΔR² + ΔG² + ΔB²) / 3)⌉ ≤ tolerance · 256`, ignoring alpha, and the tolerance is capped at the distance between the two colors. If the two colors are equal, the tool does nothing. Ctrl+click (and Ctrl+drag) picks the color under the cursor into the primary (left) or secondary (right) color, keeping the user color's alpha. |
| Text | T | Font, size (in points at 96 pixels per inch), Bold, Italic, Underline, Strikeout, alignment, Antialiasing, Alpha Blending | A click places the caret; the point is the top of the first line, and the text runs to its left, center or right according to the alignment. Typing writes in the primary color, and the first character opens a "Text" step. Enter starts a new line; Backspace / Delete, the arrow keys and Home / End work as usual (with Ctrl, they move by words and to the ends of the text). The right button, or dragging the handle at the text's corner, moves the text; changing the font, size, style or colors redraws it. A click inside the text moves the caret; a click elsewhere finishes the text and starts a new one. Esc and switching tools finish it. A click with nothing typed leaves no step. |
| Line / Curve | O | Width, start and end caps (Flat, Arrow, Arrow Filled, Rounded), dash style (Solid, Dash, Dash Dot, Dash Dot Dot, Dot), Antialiasing | Dragging draws a straight line; Shift snaps the angle to 15° steps. After the drag there are four handles: dragging a handle with the left button makes a spline, with the right button a Bézier curve (the first handle drag fixes the type). Enter or a click elsewhere finishes; Esc cancels. `,` `.` `/` cycle the start cap, the dash style and the end cap. |
| Rectangle | O | Type: outline (default) / fill / both; width, Antialiasing | Dragging draws a rectangle; Shift constrains it to a square. |
| Rounded Rectangle | O | Same | Like Rectangle, with a corner radius of 10. |
| Ellipse | O | Same | Dragging draws an ellipse inscribed in the dragged box; Shift constrains it to a circle. |
| Freeform Shape | O | Same | Dragging draws a freeform closed shape. |

Shape colors: with the left button the outline uses the primary color
and the fill uses the secondary color; the right button swaps them. For
the fill-only type, the left button fills with the primary color.
Pressing the other mouse button while dragging a shape or line moves
the whole shape.

### Common tool keys

| Key | Action |
|---|---|
| `[` / `]` | Brush width −1 / +1; with Ctrl, ±5. |
| X | Swap the primary and secondary colors. |
| C | Switch which of the two colors the Colors window edits. |
| Space (held) | Temporary Pan. |
| Esc / Enter | For a live gradient or curve, Enter finishes and Esc cancels. Otherwise both finish a move and clear the selection, if there is one and no mouse button is held. |
| Arrow keys | In the move tools, nudge by 1 pixel (10 with Ctrl); in other tools, move the mouse cursor. |

### Tool settings

Defaults: width 2, Antialiasing on, Alpha Blending on, Tolerance 50%,
Flood Mode Local, Selection Mode Replace, Resampling Bilinear, shape
type outline.

- **Width** (Brush Width): 1–500 pixels, 2 by default.
- **Antialiasing**: an antialiased edge (partial pixel coverage) or a
  hard edge (50% threshold).
- **Alpha Blending**: when on, the color is blended with the layer
  pixel (Normal); when off, it replaces the pixel, alpha included.
- **Tolerance**: 0–100%, 50% by default. A color `b` is close to the
  sample `a` if (formula from `FloodToolBase.CheckColor`)

  ```
  T = ⌊tolerance² · 256⌋                         tolerance ∈ [0, 1]
  sum = Σ_{r,g,b} ⌊(1 + (a.c − b.c)²) · a.a / 256⌋ + (a.a − b.a)²
  close ⇔ sum ≤ T² · 4
  ```

  The sample `a` is the pixel under the cursor; squaring the tolerance
  in `T` makes the slider more sensitive near zero.
- **Flood Mode**: Local fills only the contiguous region (scanline
  fill); Global takes every pixel on the canvas that is close to the
  sample.
- **Gradient type**: Linear, Linear Reflected, Diamond, Radial, Conical.
  The parameter `t ∈ [0, 1]` for a pixel `p`, with start point `s` and
  end point `e`, is:

  | Type | `t` |
  |---|---|
  | Linear | `clamp(((p − s) · (e − s)) / |e − s|², 0, 1)` |
  | Linear Reflected | as Linear, but `clamp(|t|, 0, 1)` |
  | Diamond | `clamp(|t₁| + |t₂|, 0, 1)`, where `t₂` is the projection onto the perpendicular |
  | Radial | `clamp(|p − s| / |e − s|, 0, 1)` |
  | Conical | `θ/π + offset`, where `θ = atan2(p − s)` and the offset makes `t(e) = 0`; wrapped into `[−1, 1]`, then `|t|` |

  `t` is computed at the integer pixel point `p = (x, y)`, as in the
  source, and quantized to a byte as `⌊t · 255⌋`. In Color mode the
  color is `ColorBgra.Blend` of the start and end colors with weight
  `t`, with color weighted by each end's alpha (so toward a transparent
  end, red stays red and only alpha falls). With Alpha Blending it is
  blended Normal over the layer; without it (or when both alphas are
  255) it replaces the pixel. In Transparency mode only the layer's
  alpha changes; the target alpha is `start.a + (255 − end.a − start.a) · t`.
  With Alpha Blending the pixel's alpha is multiplied by it; without,
  the pixel's alpha is replaced by it. If the start and end points
  coincide, the whole area gets the end value.
- **Hardness**: 0–100%. Paint.NET 3.36 does not have it (it was added
  in 4.x). At 100% the brush has a hard rim; below that, the brush's
  edge falls off from `hardness · r` to `r`. The default is 100%, so
  without touching it the behaviour matches 3.36. In the tool strip it
  follows Brush Width and is shown for Paintbrush and Eraser.

## History

- The first history entry is "New Image" or "Open Image" and cannot be
  undone; "go to start" leads to it.
- Each completed action is one step, named after the action (the name
  of the tool, adjustment, effect or command). Lifting a fragment,
  moving it and finishing it form a single composite step.
- Undo is Ctrl+Z and Redo is Ctrl+Y. A new action after an Undo
  discards the undone steps.
- The History window lists the steps; clicking a step jumps to it
  (several Undos or Redos at once). Its buttons are: go to start, Undo,
  Redo, go to end.
- A step stores only what changed: for pixels, the "before" and "after"
  of the 64 × 64 tiles in which something changed; for the selection,
  the two masks; for a layer, its properties or the layer itself (when
  added or deleted). No full copy of the document is made per step.
- The user colors are not recorded in history (as in Paint.NET).

## Colors

- Primary and secondary colors; X swaps them. There are buttons to swap
  the colors and to reset them to black and white. More / Less expands
  or collapses the sliders.
- The palette has exactly 96 swatches (missing ones are filled with
  white, extra ones are dropped). Left-clicking a swatch sets the
  primary color; right-clicking sets the secondary color.
- A Paint.NET palette file is UTF-8 text with one color per line as
  `AARRGGBB` (hex); `;` starts a comment. Six digits are read with
  alpha 0. The core reads and writes this format.

## Adjustments (Adjustments menu)

Adjustments act on the active layer within the selection (in
proportion to coverage where the selection edge is antialiased). Each
one is a single history step.

| Adjustment | Key | Parameters (default, range) | Algorithm |
|---|---|---|---|
| Auto-Level | Ctrl+Shift+L | — | Levels derived from the selection's histogram: low is the 0.5% percentile, high is the 99.5% percentile, and md is the mean. The channel gamma is `clamp(log_{(md−lo)/(hi−lo)} 0.5, 0.1, 10)` if `lo < md < hi`, otherwise 1. Output is black to white. |
| Black and White | Ctrl+Shift+G | — | Converts color to luminance `(7471·B + 38470·G + 19595·R) >> 16`. |
| Brightness / Contrast | Ctrl+Shift+C | Brightness 0 (−100…100), Contrast 0 (−100…100) | See the formula below. |
| Curves | Ctrl+Shift+M | Mode: Luminosity (default) or RGB; control points | A natural cubic spline through the points. Luminosity shifts all channels by the difference given by the luminosity curve. |
| Hue / Saturation | Ctrl+Shift+U | Hue 0 (−180…180), Saturation 100 (0…200), Lightness 0 (−100…100) | See the formula below. |
| Invert Colors | Ctrl+Shift+I | — | `255 − c` for RGB; alpha is unchanged. |
| Levels | Ctrl+L | Input low/high, output low/high, gamma per channel (0.1…10) | `out = lo' + (hi' − lo') · ((c − lo)/(hi − lo))^γ`. |
| Posterize | Ctrl+Shift+P | Red, Green, Blue 16 (2…64), Linked | Each channel is quantized to N levels using Paint.NET's table. |
| Sepia | Ctrl+Shift+E | — | Black and White, then Levels with gamma B 1.2, G 1.0, R 0.8. |

**Brightness / Contrast.** `i` is the pixel's luminance. For Contrast
`c < 0`: `mul = c + 100`, `div = 100`; for `c > 0`: `mul = 100`,
`div = 100 − c`; for `c = 0`: `mul = div = 1`. The channel shift is:

```
div = 100:  shift = (i − 127) · mul / div + 127 − i + brightness
otherwise:  shift = (i − 127 + brightness) · mul / div + 127 − i
out = clamp(c + shift)
```

Contrast 100 (`div = 0`) is a threshold: the result is gray 0 or 255
depending on whether `i + brightness < 128`.

**Hue / Saturation.** `k = saturation · 1024 / 100`; each channel
becomes `clamp((i · 1024 + (c − i) · k) >> 10)`. Next, the HSV hue is
shifted by Hue and wrapped into 0…360. Then Lightness blends with white
(`l > 0`) or black (`l < 0`) with weight `|l| · 255 / 100`. Alpha does
not change. Paint.NET computes HSV in integers (hue in degrees, S and V
in percent), which quantizes the color; the core computes HSV in
floating point.

## Effects (Effects menu)

This is the full list from Paint.NET 3.36 (OpenPDN); parameters are
given as default value and range. The "Core" column shows whether the
effect is already implemented in `paintbox_core`. Ctrl+F repeats the
last effect with the same parameters.

Offset moves the center, in fractions of the half-width and
half-height (0, 0 is the center of the layer). Quality sets how many
samples each pixel takes: more is smoother and slower. Seed is the
noise seed: in the source, Dents and Clouds have a seed of 0…255 mixed
with a random number per program run, and Frosted Glass differs every
time; in the core, the seed reproduces the image.

| Submenu | Effect | Parameters | Core |
|---|---|---|---|
| Artistic | Ink Sketch | Ink Outline 50 (0…99), Coloring 50 (0…100) | yes |
| Artistic | Oil Painting | Brush Size 3 (1…8), Coarseness 50 (3…255) | yes |
| Artistic | Pencil Sketch | Pencil Tip Size 2 (1…20), Color Range 0 (−20…20) | yes |
| Blurs | Fragment | Fragments 4 (2…50), Distance 8 (0…100), Rotation 0 (0…360) | yes |
| Blurs | Gaussian Blur | Radius 2 (0…200) | yes |
| Blurs | Motion Blur | Angle 25 (−180…180), Distance 10 (1…200), Centered yes | yes |
| Blurs | Radial Blur | Angle 2 (0…360), Offset 0, 0 (−2…2), Quality 2 (1…5) | yes |
| Blurs | Surface Blur | Radius 6 (1…100), Threshold 15 (1…100) | yes |
| Blurs | Unfocus | Radius 4 (1…200) | yes |
| Blurs | Zoom Blur | Amount 10 (0…100), Offset 0, 0 (−2…2) | yes |
| Distort | Bulge | Amount 45 (−200…100), Offset 0, 0 (−1…1) | yes |
| Distort | Dents | Scale 25 (1…200), Refraction 50 (0…200), Roughness 10 (0…100), Tension 10 (0…100), Quality 2 (1…5), Seed | yes |
| Distort | Frosted Glass | Max Scatter 3 (0…200), Min Scatter 0 (0…200), Samples 2 (1…8), Seed | yes |
| Distort | Pixelate | Cell Size 2 (1…100) | yes |
| Distort | Polar Inversion | Amount 1 (−4…4), Offset 0, 0 (−2…2), Edge Behavior Wrap (Clamp, Reflect, Wrap), Quality 2 (1…5) | yes |
| Distort | Tile Reflection | Rotation 30 (−180…180), Tile Size 40 (1…800), Curvature 8 (−100…100), Quality 2 (1…5) | yes |
| Distort | Twist | Amount 30 (−200…200), Size 1 (0.01…2), Offset 0, 0 (−2…2), Quality 2 (1…5) | yes |
| Noise | Add Noise | Intensity 64 (0…100), Color Saturation 100 (0…400), Coverage 100 (0…100) | yes |
| Noise | Median | Radius 10 (1…200), Percentile 50 (0…100) | yes |
| Noise | Reduce Noise | Radius 10 (0…200), Strength 0.4 (0…1) | yes |
| Photo | Glow | Radius 6 (1…20), Brightness 10 (−100…100), Contrast 10 (−100…100) | yes |
| Photo | Red Eye Removal | Tolerance 70 (0…100), Saturation 90 (0…100) | yes |
| Photo | Sharpen | Amount 2 (1…20) | yes |
| Photo | Soften Portrait | Softness 5 (0…10), Lighting 0 (−20…20), Warmth 10 (0…20) | yes |
| Photo | Vignette | Offset, Radius 0.5 (0.1…4), Amount 1 (0…1); not in the 3.36 build | — |
| Render | Clouds | Scale 250 (2…1000), Power 0.5 (0…1), Blend Mode Normal (the layer blend modes), Seed | yes |
| Render | Julia Fractal | Factor 4 (1…10), Zoom 1 (0.1…50), Angle 0 (−180…180), Quality 2 (1…5) | yes |
| Render | Mandelbrot Fractal | Factor 1 (1…10), Zoom 10 (0…100), Angle 0 (−180…180), Quality 2 (1…5), Invert Colors no | yes |
| Stylize | Edge Detect | Angle 45 (−180…180) | yes |
| Stylize | Emboss | Angle 0 (−180…180) | yes |
| Stylize | Outline | Thickness 3 (1…200), Intensity 50 (0…100) | yes |
| Stylize | Relief | Angle 45 (−180…180) | yes |

The core's effect algorithms follow the source:

- **Gaussian Blur** in Paint.NET is not Gaussian but a triangular
  kernel (weights `16·(i+1)` toward the center, separable by axis),
  with color weighted by alpha. A triangular kernel is the convolution
  of two box kernels, so the core computes it with running sums, and
  its running time does not depend on the radius.
- **Sharpen**, **Median** and **Outline** use a local histogram in a
  circle of radius `r` (a pixel is in the circle if
  `u² + v² ≤ ((2r+1)² + 2) / 4`). Median takes a channel percentile.
  Sharpen is `lerp(c, median, −0.5)` with Amount as the radius. Outline
  is `255 − (c₂ − c₁)` between the percentiles `(100 ∓ intensity)/2`.
- **Motion Blur** is the alpha-weighted average of `(1 + d)·3/2`
  bilinear samples along a segment of length `d` at the given angle;
  Centered centers the segment on the pixel.
- **Oil Painting** sorts the pixels in a `2·size+1` square into
  `coarseness` bins by intensity; the result is the average color of
  the fullest bin.
- **Emboss** is a 3 × 3 kernel with weights `cos(angle + k·45°)` applied
  to luminance, plus 128; the result is gray and opaque.
- **Edge Detect** applies the same kernel to each RGB channel without
  the offset; the result is opaque.
- **Pixelate** uses `size × size` cells starting from the canvas
  origin; the cell color is the average of the cell's four corners.
- **Add Noise** adds normal noise with standard deviation
  `intensity² / 64`; the noise saturation is relative to its
  luminance, and Coverage sets the share of pixels affected. The
  core's generator is deterministic and seeded, so the result can be
  reproduced and tested.
- **Ink Sketch** is Glow (radius 6, brightness and contrast
  `−(Coloring − 50)·2`) darkened with ink: a 5 × 5 kernel (center 30,
  the rest −1, directly below the center −5) over RGB, in gray; where
  it is not lighter than Ink Outline %, the pixel becomes black.
- **Pencil Sketch** is a blur with radius Tip Size, Brightness /
  Contrast (Range, −Range), inversion and conversion to gray; the
  result is applied with Color Dodge onto a gray layer, so flat areas
  turn white and edges remain.
- **Fragment** is the average of `Fragments` copies of the layer,
  offset by Distance and spaced evenly around a circle starting at the
  Rotation angle.
- **Radial Blur** takes the pixel and `q²(30 + q²)` samples in each
  direction along an arc around the center, spanning the Angle. The
  rotation uses the source's fixed-point arithmetic (`sin x ≈ x`,
  `cos x ≈ 1 − x²/2`), which is 64-bit in the core.
- **Surface Blur** uses the histogram of a circle of radius Radius;
  each channel is the average of the circle's values weighted by
  `255 − difference·96/Threshold` (not less than 0), so edges are not
  blurred. The pixel's alpha is kept.
- **Unfocus** is the alpha-weighted average of a circle. The source
  divides by `area·255` and darkens semi-transparent pixels; the core
  divides by the sum of alpha (which is the same for opaque pixels).
- **Zoom Blur** takes the pixel and 64 samples stepping toward the
  center, each step `Amount/16384` of the way.
- **Bulge** works inside the circle inscribed in the layer: a point at
  relative distance `t` from the edge samples at `1 − Amount/100·t²` of
  its distance from the center. Pixels outside the circle are
  unchanged.
- **Dents** displaces each point with Perlin noise (the source's
  `PerlinNoise2D`, with octaves down to the one-pixel limit): the
  direction is the noise multiplied by Tension, and the distance is
  Refraction. At the edges the layer is mirrored. The center and scale
  come from the selection bounds.
- **Frosted Glass** is the average of Samples bilinear samples at
  random points between the two scatter radii.
- **Polar Inversion** makes a point at distance `d` from the center of
  the selection sample at `R²/d` (where `R` is the radius of the circle
  inscribed in the selection), Amount of the way there; outside the
  layer, Edge Behavior applies.
- **Tile Reflection** works in axes rotated by Rotation; each axis is
  offset by `Curvature²/10 · tan(s·π/Tile Size)`, and samples wrap
  around the layer. Quality above 1 takes one level more samples, as in
  the source.
- **Twist** rotates a point around the center by `Amount²·t³/100`
  radians, where `t` falls from 1 at the center to 0 at Size times the
  radius of the inscribed circle.
- **Reduce Noise** computes, for each channel, the share of the
  circle's values below the pixel's value (0…255); the pixel moves away
  from it by `0.2·Strength`, less in light pixels.
- **Glow** is a blur followed by Brightness / Contrast, applied with
  Screen onto the layer.
- **Red Eye Removal**: a saturated pixel whose red exceeds the other
  channels by more than Tolerance gets a red value equal to its
  luminance, scaled by Saturation %.
- **Soften Portrait** is a blur with radius `3·Softness` and
  Brightness / Contrast (Lighting, −Lighting/2), applied with Overlay
  onto a gray layer that is warmed by Warmth % (more red, less blue).
- **Clouds** is up to 12 octaves of Perlin noise from the center of the
  layer; the first octave is Scale pixels, and each subsequent one is
  half as large and Power times weaker. In the source, clouds run from
  the primary color to the secondary color. A core effect does not see
  the user colors, so it draws from black to white (Paint.NET's default
  colors) and applies the result to the layer with Blend Mode.
- **Julia Fractal** renders the Julia set for `c = 0.3125 + 0.03i`,
  with up to 256 iterations and a smoothed counter. As counter·Factor
  passes 0, 256, 512 and 768, it turns on alpha, red, green and blue in
  turn.
- **Mandelbrot Fractal** renders the neighbourhood of `(−0.7, −0.29)`,
  magnified `1 + 20·Zoom` times, with up to `1024/Factor` iterations;
  the value `64 + Factor·counter` likewise turns on alpha, blue, green
  and red. Points inside the set are white (black with Invert Colors).
  The core does not iterate points in the main cardioid and the
  period-2 bulb, and it stops an orbit that returns closer than 10⁻⁶ to
  a stored point (a cycle). It iterates the remaining orbits eight at a
  time side by side, in blocks of 16 iterations, and repeats the block
  in which an orbit escaped one iteration at a time, so the counters
  match the source.
- **Relief** is the Edge Detect kernel with a center weight of 1, so
  the image remains under the relief of its edges.

Effects with a center (Bulge, Twist, Zoom Blur and Radial Blur, the
fractals, Clouds) are centered on the layer, as in the source; Dents
and Polar Inversion (`WarpEffectBase` in the source) are centered on
the selection bounds.

## Clipboard

| Command | Key | Behaviour |
|---|---|---|
| Cut | Ctrl+X, Shift+Delete | Copy, then Erase Selection (the selection is cleared). |
| Copy | Ctrl+C, Ctrl+Insert | Copies the active layer's pixels within the selection's bounding box; pixels outside the shape are transparent. |
| Paste | Ctrl+V, Shift+Insert | The pasted image becomes a lifted fragment of the Move Selected Pixels tool on the active layer (the program switches to that tool). A fragment that fits entirely within the canvas goes to its original position; otherwise it goes to the center of the canvas, and the view scrolls to it. An image from another program has position (0, 0). A fragment larger than the canvas prompts an offer to enlarge the canvas. |
| Paste into New Layer | Ctrl+Shift+V | The same, on a new layer. |
| Paste into New Image | Ctrl+Alt+V | Creates a new document the size of the fragment. |

The core treats clipboard contents as a value (a pixel fragment and its
position); the system clipboard is the front end's responsibility.

## Windows, menus and view

### Windows

| Window | Key | Contents |
|---|---|---|
| Tools | F5 | Tool buttons in the order of the tools table; the tooltip shows the name and key. |
| History | F6 | History steps and navigation buttons. |
| Layers | F7 | Layers from top to bottom with a thumbnail and a visibility check box; buttons Add, Delete, Duplicate, Merge Down, Move Up, Move Down, Properties. |
| Colors | F8 | Primary and secondary colors, color wheel, RGB/HSV/alpha sliders, hex, palette. |

Above the canvas is the active tool's settings bar (the Tool Config
Strip). The windows float and become semi-transparent while the cursor
is over the canvas.

### Menus

| Menu | Items and keys |
|---|---|
| File | New Ctrl+N, Open Ctrl+O, Close Ctrl+W, Save Ctrl+S, Save As Ctrl+Shift+S, Print Ctrl+P, Exit |
| Edit | Undo Ctrl+Z, Redo Ctrl+Y, Cut, Copy, Paste, Paste into New Layer, Paste into New Image, Erase Selection Del, Fill Selection Backspace, Invert Selection Ctrl+I, Select All Ctrl+A, Deselect Ctrl+D |
| View | Zoom In Ctrl++, Zoom Out Ctrl+−, Zoom to Window Ctrl+B, Zoom to Selection Ctrl+Shift+B, Actual Size Ctrl+Shift+A (and Ctrl+Alt+0), Grid, Rulers, units |
| Image | Crop to Selection Ctrl+Shift+X, Resize Ctrl+R, Canvas Size Ctrl+Shift+R, Flip Horizontal, Flip Vertical, Rotate 90° CW Ctrl+H, Rotate 90° CCW Ctrl+G, Rotate 180° Ctrl+J, Flatten Ctrl+Shift+F |
| Layers | See "Layer commands" |
| Adjustments | See "Adjustments" |
| Effects | Repeat Ctrl+F; submenus as in the effects table |
| Window | Tools F5, History F6, Layers F7, Colors F8, next/previous tab Ctrl+Tab / Ctrl+Shift+Tab |
| Help | Help F1 |

Resize changes the image size (all layers) with resampling. Canvas
Size changes the canvas without scaling, using an anchor (nine
positions); the new area is transparent (filled with the secondary
color in the Background layer).

### Zoom and scrolling

- Zoom In and Zoom Out step through 1, 2, 3, 4, 5, 6, 8, 12, 16, 25,
  33, 50, 66, 100, 200, 300, 400, 500, 600, 700, 800, 1200, 1600, 2400
  and 3200%.
- The mouse wheel scrolls vertically by 120 screen pixels per notch,
  Shift+wheel scrolls horizontally, and Ctrl+wheel (Ctrl alone) zooms
  smoothly around the cursor (×1.12 per notch, not in steps).
- The key of a disabled command (such as Delete with no selection) does
  nothing and does not finish a live gradient or move.
- The area outside the canvas is gray; transparency inside the canvas
  is shown as a checkerboard.

### Status bar

The status bar shows the active tool's hint, the cursor coordinates,
the selection size, the units (pixels, inches, centimeters), the zoom
level and the progress of a long operation.

## Files

| Format | Read | Write | What it stores |
|---|---|---|---|
| OpenRaster `.ora` | yes | yes | Layers with names, visibility, opacity and blend modes. Paintbox's native format. |
| PNG | yes | yes | A flat image with alpha. |
| JPEG | yes | yes | A flat image without alpha (composited onto white), quality 95. |
| BMP | yes | yes | A flat image. |
| TGA | yes | yes | A flat image with alpha. |
| WebP | yes | yes | A flat image with alpha; written losslessly. |

A flat file opens as a document with a single "Background" layer; flat
saving composites the visible layers into one image. GIF, TIFF and DDS,
which Paint.NET 3.36 can open, were deliberately left out.

### OpenRaster

The `.pdn` format of current Paint.NET is closed. Version 3 `.pdn` is
described in the OpenPDN code (a `PDN3` header, an XML header and
gzip-compressed chunks), but its layer properties use binary .NET
serialization. Paintbox therefore uses OpenRaster as its layered
format: it is open and is read by GIMP, Krita and MyPaint. The file is
a zip archive:

```
mimetype              first, uncompressed: "image/openraster"
stack.xml             <image w h version="0.0.3"><stack> layers from top to bottom </stack></image>
data/layer0.png …     one PNG per layer, straight RGBA
mergedimage.png       the flattened result
Thumbnails/thumbnail.png   at most 256 × 256
```

Layer attributes: `name`, `src`, `x`, `y`, `opacity` (0…1),
`visibility` (`visible` / `hidden`), `composite-op`. Blend modes map as
follows:

| Mode | `composite-op` |
|---|---|
| Normal | `svg:src-over` |
| Multiply | `svg:multiply` |
| Additive | `svg:plus` |
| Color Burn | `svg:color-burn` |
| Color Dodge | `svg:color-dodge` |
| Overlay | `svg:overlay` |
| Difference | `svg:difference` |
| Lighten | `svg:lighten` |
| Darken | `svg:darken` |
| Screen | `svg:screen` |
| Reflect, Glow, Negation, Xor | `paintbox:reflect`, `paintbox:glow`, `paintbox:negation`, `paintbox:xor` |

In OpenRaster, `svg:xor` is the Porter-Duff XOR, not Paint.NET's
bitwise Xor, so Xor is written under its own name. An unknown mode
becomes Normal when reading. Nested stacks (Krita groups) are read as
a flat list of layers, without the group properties. A layer smaller
than the canvas is placed at `x`, `y`.

## Decisions

- **Straight RGBA8**: see "Pixel format".
- **The selection is a 0–255 mask with a "has selection" flag**, not a
  set of polygons. Combine operations are per pixel, and GPC is not
  needed. Selection tools produce a hard edge (0 or 255), like
  Paint.NET's clipping; the intermediate values are kept for feathering
  the edge in the future. The flag is needed because "zero pixels
  selected" and "nothing selected" behave differently. The front end
  builds the selection outline ("marching ants") from the mask.
- **Strokes go through a stroke mask.** Paintbrush, Eraser, Clone Stamp
  and Recolor accumulate the stroke's coverage (the maximum over
  segments) and each time recomposite the changed area from the saved
  original. As a result, a semi-transparent stroke is even, without the
  "beads" at segment joints that Paint.NET 3.36 produces.
- **Brush hardness** was added even though 3.36 does not have it.
- **History in 64 × 64 tiles**: an action saves a tile's original the
  first time it touches the tile; on completion, only the tiles that
  actually changed go into the step, as "before" and "after".
- **Seeded noise**: Add Noise is deterministic for testing and
  repetition (Ctrl+F gives the same noise for the same seed).
- **Percentile without the off-by-one.** `GetPercentile` in OpenPDN and
  Pinta takes one more step after finding the value, so the median of a
  flat background of 100 gives 101, and Median, Sharpen and Outline
  lighten the image slightly on every application. The core returns the
  value it found.
- **Gaussian Blur** is computed with two running sums along each axis
  in floating point. The result differs from the integer source by at
  most one channel unit, and the running time does not depend on the
  radius.
- **Editing from originals.** Gradient, shapes, fill, adjustments and
  effects inside an open edit (`begin_edit`) are redrawn each time from
  the saved tile originals. This lets the front end show a drag or a
  dialog live while history receives a single step. An action that
  changed nothing records no step.
- **Previews for the front end.** Inside an open edit, a selection (a
  drag in Union or Xor mode) is combined with the selection the edit
  started from. The Layer Properties dialog shows changes through
  `preview_layer_properties` and records one step on OK. The front end
  renders a slow effect on a worker thread from `effect_source` and
  pastes the result with `apply_rendered`, so the interface does not
  freeze.
- **Input limits.** Pointer coordinates are limited to ±10⁶ pixels, NaN
  becomes zero, and a pencil line is clipped to the canvas. A single
  surface is at most 2²⁷ pixels (512 MiB), memory is allocated with a
  check, and PNGs inside files and zip entries are read with a size
  limit. Invalid input therefore produces an `Error`, not a panic or a
  process crash.
- **Small matches with the source**: transparent over transparent gives
  transparent black; curves truncate fractions (like `ClampToByte`), and
  a repeated curve point replaces the previous one; Levels allows equal
  output bounds. Rounding in Sharpen, in average colors and in Hue /
  Saturation lightness (where the source divides by 256) stays within
  one channel unit.
- **The right button for a gradient in Transparency mode** simply swaps
  the colors, as in Color mode; the finer points of the source
  (inverting the alphas) are left for later.
- **Parallelism**: rows of effects and compositing are split between
  threads with `std::thread::scope`, without external crates.
- **Core libraries**: `image` (PNG, JPEG, BMP, TGA and WebP codecs),
  `zip` (ORA), `serde`/`serde_json` (settings) and `thiserror`. The
  `stack.xml` file is written and read by hand because the format is
  small.
- **Text** uses `ab_glyph` with its own outline rasterization. The
  built-in font is Manrope (SIL OFL, Latin and Cyrillic); system fonts
  are found by family name: the core scans the system font folders
  once (Windows, macOS, Linux), reading only the `name` and `OS/2`
  tables of each file. The regular weight of a variable font is 400
  (Manrope's default instance is 200). Bold uses the family's bold face
  or the `wght` axis (700); otherwise the glyph is drawn twice with an
  offset of `size / 24`. Italic uses the italic face; otherwise the
  glyph is slanted by 0.21 (as in GDI+). Underline and strikeout are
  bars `size / 16` thick. The caret is an overlay guide (two points),
  and the move handle is at the top-left corner of the text. Each glyph
  is rasterized within its own rectangle and only where it overlaps the
  canvas, so large text costs only as much as is visible; a change that
  could not be drawn is rolled back. Esc keeps the typed text, as in
  Paint.NET 3.36.
- **Line / Curve caps and dashes** follow the GDI+ pen used by
  Paint.NET. The arrow is `AdjustableArrowCap(5, 5)`: five widths long
  and five wide, with the tip at the end of the line and the line
  stopping at the arrow's base. Rounded is a semicircle. Dash lengths
  are in pen widths (Dash 3–1, Dash Dot 3–1–1–1, Dash Dot Dot
  3–1–1–1–1–1, Dot 1–1); dash ends are flat and joins are round.
  `,` `.` `/` cycle the start cap, the dash style and the end cap.
- **Name**: the program is called Paintbox; "Paint.NET" is not used in
  the program or its files.
- **Rotating and scaling a lifted fragment** is a transform around its
  center: an offset (in whole pixels), an angle and a scale along the
  fragment's own axes. Eight handles (corners and side midpoints) are
  in the session overlay while the pixels are lifted. A handle drags
  its own side while the opposite side stays fixed (Shift on a corner
  scales proportionally). The right button rotates (Shift snaps to 15°
  steps). Dragging a side past the opposite side mirrors the fragment.
  While moving, nearest-neighbour sampling is used; on finishing, the
  tool strip's Resampling (Bilinear) is used. The selection is
  transformed with the same sampling of its mask.
- **Moving as a single step.** Paint.NET 3.36 records a "Move Pixels"
  step for each drag or arrow-key nudge and a "Finish Pixels" step on
  finishing. Paintbox records everything from lifting to finishing as a
  single "Move Selected Pixels" step (the core's edit stays open).
  Undo during a move puts the pixels back in one step.
- **The selection mode is fixed when the button is pressed**, as in the
  source (`SelectionTool`): Ctrl or Alt pressed in the middle of a drag
  does not change the mode.
- **Saving a multi-layer image to a flat format** first asks, then
  merges the layers with a "Flatten" step, as Paint.NET does; Undo
  restores the layers.
- **Front-end logic lives in the core.** Tools, tool strip settings,
  key cycles (by letter, not by toolkit key code), the gesture
  controller, commands with their availability and keys (keys with
  toolkit-neutral names), dialogs with preview, and cancellation of effect
  rendering all live in `paintbox_core`, so every front end has the
  same behaviour. An image open in the front end is a core `Session`
  (document, controller, dialog, held button, saved state); the bridge
  only translates types. A cancelled or outdated render stops at the
  next row (`Effect::render_cancellable`).

### In the Flutter program

- **Tool letters.** The letter is the one on the key when it is Latin
  (AZERTY and QWERTZ keep their own letters, as in the source, which
  compares the typed character). When it is not (for example, a
  Ukrainian layout, or Ctrl+Я), the key's position on the US layout is
  used. A held key repeats for arrow keys, brackets and Ctrl commands
  (Ctrl+Z), but not for letters: holding S does not cycle through
  tools. While any mouse button is pressed (and during view drags),
  letters have no effect.
- **The middle button pans in every tool** (in 3.36, only in Zoom).
  While a tool's button is held, neither the middle button nor Space
  takes over the drag: the other button stays with the core (moving the
  shape).
- **Space + right button** scrolls continuously toward the cursor.
  OpenPDN 3.36 does not have this (in Pan mode only the left button
  works there); it was added as in later versions.
- **Wheel and touchpad.** A wheel notch is normalized to the display
  scale (×1.12 per notch at any scale). Ctrl+wheel requires Ctrl alone,
  without Alt. Shift+wheel scrolls sideways (including where the system
  itself turns it into horizontal scrolling). Two fingers on a touchpad
  scroll, and a pinch zooms around the point between the fingers.
- **Pasting and importing an image larger than the canvas** asks
  whether to enlarge the canvas (from the top-left corner; the new area
  is transparent or, in the Background layer, the secondary color), as
  Paint.NET does. "No" pastes the image as is; dismissing the prompt
  does nothing.
- **One file at a time.** While a file is being read or written, Open,
  Save, Save As, Close and Exit are unavailable. Painting can continue:
  the program writes a snapshot of the layers taken at the moment of
  saving, and that state is the one considered saved.
- **Dialogs with preview** appear above the canvas at the top center,
  without dimming. While a dialog is open, the canvas, tools, history
  and keys wait (Enter is OK, Esc is Cancel).
- **The top of the window follows Paint.NET 5.** The menu bar holds
  File, Edit, View, Image, Layers, Adjustments and Effects. Window and
  Help became buttons in the right corner (Tools, History, Layers,
  Colors, settings, help) on the same row as the menu items, and each
  menu item is as tall as a button. Next and previous tab are available
  only through Ctrl+Tab / Ctrl+Shift+Tab and by clicking.
- **Image tabs** show a thumbnail with the file name below it. The
  thumbnail (the shape of the canvas) sets the width, not the name, so
  a long name is shortened with "…" in the middle (the end, a number or
  extension, is kept), and the full name is in the tooltip. After the
  tabs, as in Paint.NET 5, a "▾" button lists the open images with the
  active one marked, plus next and previous.
- **Drag and drop.**
  - Files dropped onto the window each open in a new tab; folders are
    skipped. This matches `MainForm.OnDragDrop` in 3.36, but without
    its "Open / Import as layers" question: to import as layers, use
    Layers > Import From File. While files are over the window, an
    "Open" hint is shown.
  - An image from a browser or another program arrives as a file
    (`CF_HDROP`; the browser puts it in the system's temporary
    folder). Such a file opens without a name, so that Save asks where
    to save it, as Pinta does for an `http` source. Links and raster
    data without a file are not accepted: the drag-and-drop module
    reads only files.
  - A tab can be dragged to another place in the tab strip, and a
    layer to another place in the Layers window. The item follows the
    pointer along the list, its original slot is semi-transparent, and
    an accent line in the gap shows where it will land; released next
    to itself, it does not move. A layer is moved in one history step
    (Move Layer Up or Down, depending on the direction), and the moved
    layer becomes active.
  - A palette swatch dropped onto the primary or secondary color
    becomes that color; the square under the swatch is highlighted.
  - A floating window is dragged by its title bar; its position (the
    offset from its corner) is remembered between runs.
  - The canvas view is moved by dragging with the middle button, or
    with the left button while holding Space.
- **Colors: More and Less.** More shows the wheel, the RGB and HSV
  sliders, hex and opacity, and the whole palette (96). Less shows the
  wheel with the opacity slider and hex below it, and the palette in
  two rows of eight; nothing is wider than the wheel. The mode is
  remembered.
- **Tool strip: icon or name.** The rule is derived from OpenPDN 3.36's
  `ToolConfigStrip`. Values that a picture can distinguish, and of
  which there are few, are icons (a `ToolStripSplitButton` with
  `DisplayStyle.Image`, or a row of `ToolStripButton`s). Values of which
  there are many, or that a picture cannot distinguish, are shown as
  the selected name in a drop-down list (`ComboBoxStyle.DropDownList`).
  A number is a field, and a fraction is a slider. Groups are separated
  by a divider (`ToolStripSeparator`), and labels appear where the
  source has them. A 3.36 split button becomes a row of buttons with
  the selected one highlighted (as in Paint.NET 5), unless the row
  would be too long. Line caps and dash style remain an icon with a
  menu, because three rows of 4–5 buttons would overload the strip.
  The selected value in a row is drawn in the accent color on a
  highlighted button; the rest are muted.

  | Setting | In 3.36 | Here |
  |---|---|---|
  | Selection Mode (5) | split button, icon; label | row of icons; label |
  | Selection size mode (Normal, Fixed Ratio, Fixed Size) | split button, icon and text; label | drop-down list with icon and name; label |
  | Selection width and height | text fields, swap button | fields with − and +, swap button |
  | Flood Mode (2) | split button, icon; label | row of icons; label |
  | Tolerance | slider; label | slider with percent; label |
  | Brush Width | combo box, − and + buttons; label | field with − and +; label |
  | Hardness (from 4.x) | — | slider; label |
  | Shape type (3) | split button, icon, click cycles; before the width | row of icons; before the width |
  | Gradient type (5) | row of icon buttons, selected one checked | row of icons |
  | Gradient channels (Color, Transparency) | split button, icon | row of icons |
  | Start and end caps (4), dash style (5) | split button, icon; label "Style" | icon with a menu (icons and names); label |
  | Antialiasing, Alpha Blending | split button, icon changes with state | single button, icon changes, highlighted when on |
  | Font | list with name; label | list with name; label |
  | Font size | combo box with a list of sizes | field with − and + |
  | Bold, Italic, Underline (and here Strikeout) | icon buttons | icon buttons |
  | Alignment (3) | row of icon buttons | row of icons |
  | Resampling | list with name; label | list with name; label |
  | Color Picker: after click (3) | list with name; label | list with name; label |
  | Fill (solid or hatch) | list with name and sample; label | none: the core paints only solid fills |
  | Font smoothing (Smooth, Sharp) | list with name | none: Antialiasing is used instead |
  | Selection size units | list with name | none: size is in pixels only |

## Open items

- **Rotating and scaling the selection outline** (Move Selection) and
  Layer Rotate / Zoom: the core can do this only for lifted pixels.
- **Curves of the Line / Curve tool**: the core rasterizes the
  polyline, spline and Bézier curve from the points; editing with
  handles is the front end's responsibility.
- **Fill antialiasing** (Paint Bucket with Antialiasing): the core
  fills without an antialiased edge.
- **Vignette** (Photo): the file is among the 3.36 sources but is not
  part of the effects build, so 3.36 has no such menu item; the core
  does not implement it.
- **Hatch brushes** (Brush Type: hatch) from Paint.NET have not been
  ported.
- **Document units and DPI** are not stored. The status bar and Fixed
  Size in Rectangle Select depend on them; ORA `xres`/`yres` gives only
  the DPI, and the display units are a program setting.
- **Resize**: the core supports Nearest and Bilinear (with smoothing
  when downscaling); the aspect-ratio lock and percentages are up to
  the front end's dialog.
- **Read-only `.pdn` 3.x import** may be added later.
- **Multiple layer selection** (Ctrl+click in the Layers window) is the
  front end's responsibility; core commands act on the active layer.
- **Front-end details not yet implemented**: a Ctrl tap (up to 400 ms)
  hides the live gradient's handles; Shift+click with Recolor shifts
  the second color by the same difference; arrow keys in other tools
  move the mouse cursor; Print (Ctrl+P); Ctrl+PageUp / PageDown and
  Ctrl+F4 for tabs.
