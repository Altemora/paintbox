//! Every menu item as a value, with its label and shortcut keys: the
//! menu bar, the keyboard and the toolbar of any shell run the same
//! commands. Keys are named as egui names them (`"Z"`, `"Delete"`,
//! `"Plus"`, `"F4"`); a shell maps its own key codes to the names.
//! [`Document::can_run`] and [`Document::run`] cover the commands that
//! need only the image; files, the clipboard, windows and the view are
//! the shell's.

use crate::adjust::{Adjustment, Curves, Levels};
use crate::document::Document;
use crate::effects::Effect;
use crate::error::Result;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AdjustmentKind {
    AutoLevel,
    BlackAndWhite,
    BrightnessContrast,
    Curves,
    HueSaturation,
    InvertColors,
    Levels,
    Posterize,
    Sepia,
}

impl AdjustmentKind {
    pub const ALL: [AdjustmentKind; 9] = [
        AdjustmentKind::AutoLevel,
        AdjustmentKind::BlackAndWhite,
        AdjustmentKind::BrightnessContrast,
        AdjustmentKind::Curves,
        AdjustmentKind::HueSaturation,
        AdjustmentKind::InvertColors,
        AdjustmentKind::Levels,
        AdjustmentKind::Posterize,
        AdjustmentKind::Sepia,
    ];

    /// The adjustment with the dialog's starting values.
    pub fn default_adjustment(self) -> Adjustment {
        match self {
            AdjustmentKind::AutoLevel => Adjustment::AutoLevel,
            AdjustmentKind::BlackAndWhite => Adjustment::BlackAndWhite,
            AdjustmentKind::BrightnessContrast => Adjustment::BrightnessContrast {
                brightness: 0,
                contrast: 0,
            },
            AdjustmentKind::Curves => Adjustment::Curves(Curves::default()),
            AdjustmentKind::HueSaturation => Adjustment::HueSaturation {
                hue: 0,
                saturation: 100,
                lightness: 0,
            },
            AdjustmentKind::InvertColors => Adjustment::InvertColors,
            AdjustmentKind::Levels => Adjustment::Levels(Levels::default()),
            AdjustmentKind::Posterize => Adjustment::Posterize {
                red: 16,
                green: 16,
                blue: 16,
            },
            AdjustmentKind::Sepia => Adjustment::Sepia,
        }
    }

    /// Applied at once, without a dialog.
    pub fn is_immediate(self) -> bool {
        matches!(
            self,
            AdjustmentKind::AutoLevel
                | AdjustmentKind::BlackAndWhite
                | AdjustmentKind::InvertColors
                | AdjustmentKind::Sepia
        )
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum EffectKind {
    InkSketch,
    OilPainting,
    PencilSketch,
    Fragment,
    GaussianBlur,
    MotionBlur,
    RadialBlur,
    SurfaceBlur,
    Unfocus,
    ZoomBlur,
    Bulge,
    Dents,
    FrostedGlass,
    Pixelate,
    PolarInversion,
    TileReflection,
    Twist,
    AddNoise,
    Median,
    ReduceNoise,
    Glow,
    RedEyeRemoval,
    Sharpen,
    SoftenPortrait,
    Clouds,
    JuliaFractal,
    MandelbrotFractal,
    EdgeDetect,
    Emboss,
    Outline,
    Relief,
}

impl EffectKind {
    /// Submenus of the Effects menu, as Paint.NET groups and orders them.
    pub const MENU: [(&'static str, &'static [EffectKind]); 7] = {
        use EffectKind::*;
        [
            ("Artistic", &[InkSketch, OilPainting, PencilSketch]),
            (
                "Blurs",
                &[
                    Fragment,
                    GaussianBlur,
                    MotionBlur,
                    RadialBlur,
                    SurfaceBlur,
                    Unfocus,
                    ZoomBlur,
                ],
            ),
            (
                "Distort",
                &[
                    Bulge,
                    Dents,
                    FrostedGlass,
                    Pixelate,
                    PolarInversion,
                    TileReflection,
                    Twist,
                ],
            ),
            ("Noise", &[AddNoise, Median, ReduceNoise]),
            ("Photo", &[Glow, RedEyeRemoval, Sharpen, SoftenPortrait]),
            ("Render", &[Clouds, JuliaFractal, MandelbrotFractal]),
            ("Stylize", &[EdgeDetect, Emboss, Outline, Relief]),
        ]
    };

    /// The effect with the dialog's starting values, as the source's
    /// property defaults.
    pub fn default_effect(self) -> Effect {
        match self {
            EffectKind::InkSketch => Effect::InkSketch {
                ink_outline: 50,
                coloring: 50,
            },
            EffectKind::OilPainting => Effect::OilPainting {
                brush_size: 3,
                coarseness: 50,
            },
            EffectKind::PencilSketch => Effect::PencilSketch {
                tip_size: 2,
                color_range: 0,
            },
            EffectKind::Fragment => Effect::Fragment {
                fragments: 4,
                distance: 8,
                rotation: 0.0,
            },
            EffectKind::RadialBlur => Effect::RadialBlur {
                angle: 2.0,
                offset_x: 0.0,
                offset_y: 0.0,
                quality: 2,
            },
            EffectKind::SurfaceBlur => Effect::SurfaceBlur {
                radius: 6,
                threshold: 15,
            },
            EffectKind::Unfocus => Effect::Unfocus { radius: 4 },
            EffectKind::ZoomBlur => Effect::ZoomBlur {
                amount: 10,
                offset_x: 0.0,
                offset_y: 0.0,
            },
            EffectKind::Bulge => Effect::Bulge {
                amount: 45,
                offset_x: 0.0,
                offset_y: 0.0,
            },
            EffectKind::Dents => Effect::Dents {
                scale: 25.0,
                refraction: 50.0,
                roughness: 10.0,
                tension: 10.0,
                quality: 2,
                seed: 0,
            },
            EffectKind::FrostedGlass => Effect::FrostedGlass {
                max_scatter: 3.0,
                min_scatter: 0.0,
                samples: 2,
                seed: 0,
            },
            EffectKind::PolarInversion => Effect::PolarInversion {
                amount: 1.0,
                offset_x: 0.0,
                offset_y: 0.0,
                edge_behavior: 2,
                quality: 2,
            },
            EffectKind::TileReflection => Effect::TileReflection {
                rotation: 30.0,
                tile_size: 40.0,
                curvature: 8.0,
                quality: 2,
            },
            EffectKind::Twist => Effect::Twist {
                amount: 30.0,
                size: 1.0,
                offset_x: 0.0,
                offset_y: 0.0,
                quality: 2,
            },
            EffectKind::ReduceNoise => Effect::ReduceNoise {
                radius: 10,
                strength: 0.4,
            },
            EffectKind::Glow => Effect::Glow {
                radius: 6,
                brightness: 10,
                contrast: 10,
            },
            EffectKind::RedEyeRemoval => Effect::RedEyeRemoval {
                tolerance: 70,
                saturation: 90,
            },
            EffectKind::SoftenPortrait => Effect::SoftenPortrait {
                softness: 5,
                lighting: 0,
                warmth: 10,
            },
            EffectKind::Clouds => Effect::Clouds {
                scale: 250,
                power: 0.5,
                blend_mode: 0,
                seed: 0,
            },
            EffectKind::JuliaFractal => Effect::JuliaFractal {
                factor: 4.0,
                zoom: 1.0,
                angle: 0.0,
                quality: 2,
            },
            EffectKind::MandelbrotFractal => Effect::MandelbrotFractal {
                factor: 1,
                zoom: 10.0,
                angle: 0.0,
                quality: 2,
                invert_colors: false,
            },
            EffectKind::Relief => Effect::Relief { angle: 45.0 },
            EffectKind::GaussianBlur => Effect::GaussianBlur { radius: 2 },
            EffectKind::MotionBlur => Effect::MotionBlur {
                angle: 25.0,
                distance: 10,
                centered: true,
            },
            EffectKind::Pixelate => Effect::Pixelate { cell_size: 2 },
            EffectKind::AddNoise => Effect::AddNoise {
                intensity: 64,
                saturation: 100,
                coverage: 100.0,
                seed: 1,
            },
            EffectKind::Median => Effect::Median {
                radius: 10,
                percentile: 50,
            },
            EffectKind::Sharpen => Effect::Sharpen { amount: 2 },
            EffectKind::EdgeDetect => Effect::EdgeDetect { angle: 45.0 },
            EffectKind::Emboss => Effect::Emboss { angle: 0.0 },
            EffectKind::Outline => Effect::Outline {
                thickness: 3,
                intensity: 50,
            },
        }
    }

    pub fn name(self) -> &'static str {
        self.default_effect().name()
    }

    /// The kind of an effect with its parameters.
    pub fn of(effect: &Effect) -> EffectKind {
        let same = |k: &&EffectKind| {
            std::mem::discriminant(&k.default_effect()) == std::mem::discriminant(effect)
        };
        // Every effect has its kind in ALL (a test checks it).
        *EffectKind::ALL
            .iter()
            .find(same)
            .unwrap_or(&EffectKind::GaussianBlur)
    }
}

impl AdjustmentKind {
    /// The kind of an adjustment with its parameters.
    pub fn of(adjustment: &Adjustment) -> AdjustmentKind {
        let same = |k: &&AdjustmentKind| {
            std::mem::discriminant(&k.default_adjustment()) == std::mem::discriminant(adjustment)
        };
        *AdjustmentKind::ALL
            .iter()
            .find(same)
            .unwrap_or(&AdjustmentKind::Levels)
    }
}

impl Adjustment {
    /// `adjust:levels`: the command that opens its dialog.
    pub fn id(&self) -> String {
        Command::Adjust(AdjustmentKind::of(self)).id()
    }

    /// Applied at once, without a dialog.
    pub fn is_immediate(&self) -> bool {
        AdjustmentKind::of(self).is_immediate()
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Command {
    New,
    Open,
    Close,
    Save,
    SaveAs,
    Exit,
    Undo,
    Redo,
    Cut,
    Copy,
    Paste,
    PasteIntoNewLayer,
    PasteIntoNewImage,
    EraseSelection,
    FillSelection,
    InvertSelection,
    SelectAll,
    Deselect,
    ZoomIn,
    ZoomOut,
    ZoomToWindow,
    ZoomToSelection,
    ActualSize,
    PixelGrid,
    CropToSelection,
    Resize,
    CanvasSize,
    FlipHorizontal,
    FlipVertical,
    Rotate90Cw,
    Rotate90Ccw,
    Rotate180,
    Flatten,
    AddLayer,
    DeleteLayer,
    DuplicateLayer,
    MergeLayerDown,
    ImportFromFile,
    FlipLayerHorizontal,
    FlipLayerVertical,
    MoveLayerUp,
    MoveLayerDown,
    LayerProperties,
    Adjust(AdjustmentKind),
    RepeatEffect,
    Effect(EffectKind),
    ToggleTools,
    ToggleHistory,
    ToggleLayers,
    ToggleColors,
    NextImage,
    PreviousImage,
    Help,
}

/// A key with its modifiers; `key` as egui names it.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Shortcut {
    pub ctrl: bool,
    pub shift: bool,
    pub alt: bool,
    pub key: &'static str,
}

/// Ctrl, Shift, Alt.
type Mods = (bool, bool, bool);

const NONE: Mods = (false, false, false);
const CTRL: Mods = (true, false, false);
const CTRL_SHIFT: Mods = (true, true, false);
const CTRL_ALT: Mods = (true, false, true);
const SHIFT: Mods = (false, true, false);

const fn sc((ctrl, shift, alt): Mods, key: &'static str) -> Shortcut {
    Shortcut {
        ctrl,
        shift,
        alt,
        key,
    }
}

/// A constant slice of shortcuts (a `const fn` call is not promoted
/// to a `'static` borrow by itself).
macro_rules! keys {
    ($(($m:expr, $k:expr)),* $(,)?) => {{
        const KEYS: &[Shortcut] = &[$(sc($m, $k)),*];
        KEYS
    }};
}

impl Command {
    pub fn label(self) -> &'static str {
        use Command::*;
        match self {
            New => "New...",
            Open => "Open...",
            Close => "Close",
            Save => "Save",
            SaveAs => "Save As...",
            Exit => "Exit",
            Undo => "Undo",
            Redo => "Redo",
            Cut => "Cut",
            Copy => "Copy",
            Paste => "Paste",
            PasteIntoNewLayer => "Paste into New Layer",
            PasteIntoNewImage => "Paste into New Image",
            EraseSelection => "Erase Selection",
            FillSelection => "Fill Selection",
            InvertSelection => "Invert Selection",
            SelectAll => "Select All",
            Deselect => "Deselect",
            ZoomIn => "Zoom In",
            ZoomOut => "Zoom Out",
            ZoomToWindow => "Zoom to Window",
            ZoomToSelection => "Zoom to Selection",
            ActualSize => "Actual Size",
            PixelGrid => "Pixel Grid",
            CropToSelection => "Crop to Selection",
            Resize => "Resize...",
            CanvasSize => "Canvas Size...",
            FlipHorizontal | FlipLayerHorizontal => "Flip Horizontal",
            FlipVertical | FlipLayerVertical => "Flip Vertical",
            Rotate90Cw => "Rotate 90° Clockwise",
            Rotate90Ccw => "Rotate 90° Counter-clockwise",
            Rotate180 => "Rotate 180°",
            Flatten => "Flatten",
            AddLayer => "Add New Layer",
            DeleteLayer => "Delete Layer",
            DuplicateLayer => "Duplicate Layer",
            MergeLayerDown => "Merge Layer Down",
            ImportFromFile => "Import From File...",
            MoveLayerUp => "Move Layer Up",
            MoveLayerDown => "Move Layer Down",
            LayerProperties => "Layer Properties...",
            Adjust(kind) => match kind {
                AdjustmentKind::AutoLevel => "Auto-Level",
                AdjustmentKind::BlackAndWhite => "Black and White",
                AdjustmentKind::BrightnessContrast => "Brightness / Contrast...",
                AdjustmentKind::Curves => "Curves...",
                AdjustmentKind::HueSaturation => "Hue / Saturation...",
                AdjustmentKind::InvertColors => "Invert Colors",
                AdjustmentKind::Levels => "Levels...",
                AdjustmentKind::Posterize => "Posterize...",
                AdjustmentKind::Sepia => "Sepia",
            },
            RepeatEffect => "Repeat",
            Effect(kind) => kind.name(),
            ToggleTools => "Tools",
            ToggleHistory => "History",
            ToggleLayers => "Layers",
            ToggleColors => "Colors",
            NextImage => "Next Image",
            PreviousImage => "Previous Image",
            Help => "Help Topics",
        }
    }

    /// The keys, the first one shown in the menu.
    pub fn shortcuts(self) -> &'static [Shortcut] {
        use Command::*;
        match self {
            New => keys![(CTRL, "N")],
            Open => keys![(CTRL, "O")],
            Close => keys![(CTRL, "W")],
            Save => keys![(CTRL, "S")],
            SaveAs => keys![(CTRL_SHIFT, "S")],
            Undo => keys![(CTRL, "Z")],
            Redo => keys![(CTRL, "Y")],
            Cut => keys![(CTRL, "X"), (SHIFT, "Delete")],
            Copy => keys![(CTRL, "C"), (CTRL, "Insert")],
            Paste => keys![(CTRL, "V"), (SHIFT, "Insert")],
            PasteIntoNewLayer => keys![(CTRL_SHIFT, "V")],
            PasteIntoNewImage => keys![(CTRL_ALT, "V")],
            EraseSelection => keys![(NONE, "Delete")],
            FillSelection => keys![(NONE, "Backspace")],
            InvertSelection => keys![(CTRL, "I")],
            SelectAll => keys![(CTRL, "A")],
            Deselect => keys![(CTRL, "D")],
            ZoomIn => keys![(CTRL, "Plus"), (CTRL, "Equals"), (CTRL_SHIFT, "Equals"),],
            ZoomOut => keys![(CTRL, "Minus")],
            ZoomToWindow => keys![(CTRL, "B")],
            ZoomToSelection => keys![(CTRL_SHIFT, "B")],
            ActualSize => keys![(CTRL_SHIFT, "A"), (CTRL_ALT, "0")],
            CropToSelection => keys![(CTRL_SHIFT, "X")],
            Resize => keys![(CTRL, "R")],
            CanvasSize => keys![(CTRL_SHIFT, "R")],
            Rotate90Cw => keys![(CTRL, "H")],
            Rotate90Ccw => keys![(CTRL, "G")],
            Rotate180 => keys![(CTRL, "J")],
            Flatten => keys![(CTRL_SHIFT, "F")],
            AddLayer => keys![(CTRL_SHIFT, "N")],
            DeleteLayer => keys![(CTRL_SHIFT, "Delete")],
            DuplicateLayer => keys![(CTRL_SHIFT, "D")],
            MergeLayerDown => keys![(CTRL, "M")],
            LayerProperties => keys![(NONE, "F4")],
            Adjust(kind) => match kind {
                AdjustmentKind::AutoLevel => keys![(CTRL_SHIFT, "L")],
                AdjustmentKind::BlackAndWhite => keys![(CTRL_SHIFT, "G")],
                AdjustmentKind::BrightnessContrast => keys![(CTRL_SHIFT, "C")],
                AdjustmentKind::Curves => keys![(CTRL_SHIFT, "M")],
                AdjustmentKind::HueSaturation => keys![(CTRL_SHIFT, "U")],
                AdjustmentKind::InvertColors => keys![(CTRL_SHIFT, "I")],
                AdjustmentKind::Levels => keys![(CTRL, "L")],
                AdjustmentKind::Posterize => keys![(CTRL_SHIFT, "P")],
                AdjustmentKind::Sepia => keys![(CTRL_SHIFT, "E")],
            },
            RepeatEffect => keys![(CTRL, "F")],
            ToggleTools => keys![(NONE, "F5")],
            ToggleHistory => keys![(NONE, "F6")],
            ToggleLayers => keys![(NONE, "F7")],
            ToggleColors => keys![(NONE, "F8")],
            NextImage => keys![(CTRL, "Tab")],
            PreviousImage => keys![(CTRL_SHIFT, "Tab")],
            Help => keys![(NONE, "F1")],
            _ => keys![],
        }
    }

    /// The menu's shortcut text.
    pub fn shortcut_text(self) -> String {
        let Some(&first) = self.shortcuts().first() else {
            return String::new();
        };
        let mut text = String::new();
        if first.ctrl {
            text.push_str("Ctrl+");
        }
        if first.shift {
            text.push_str("Shift+");
        }
        if first.alt {
            text.push_str("Alt+");
        }
        text.push_str(match first.key {
            "Plus" => "+",
            "Minus" => "-",
            "Delete" => "Del",
            "Insert" => "Ins",
            key => key,
        });
        text
    }

    /// The command a key press runs, if any; modifiers must match
    /// exactly, so Ctrl+Z is not Ctrl+Shift+Z.
    pub fn for_shortcut(ctrl: bool, shift: bool, alt: bool, key: &str) -> Option<Command> {
        ALL.iter().copied().find(|c| {
            c.shortcuts()
                .iter()
                .any(|s| s.key == key && (s.ctrl, s.shift, s.alt) == (ctrl, shift, alt))
        })
    }

    /// Every command that has keys or a menu item.
    pub fn all() -> &'static [Command] {
        ALL
    }

    /// A stable snake_case name for shells and scripts: `undo`,
    /// `adjust:levels`, `effect:gaussian_blur`.
    pub fn id(self) -> String {
        match self {
            Command::Adjust(kind) => format!("adjust:{}", kind.id()),
            Command::Effect(kind) => format!("effect:{}", kind.id()),
            other => snake(&format!("{other:?}")),
        }
    }

    pub fn from_id(id: &str) -> Option<Command> {
        if let Some(kind) = id.strip_prefix("effect:") {
            return EffectKind::ALL
                .iter()
                .find(|k| k.id() == kind)
                .map(|&k| Command::Effect(k));
        }
        ALL.iter().copied().find(|c| c.id() == id)
    }

    /// Whether the command changes the image alone, so
    /// [`Document::run`] can carry it out.
    pub fn is_document_command(self) -> bool {
        use Command::*;
        matches!(
            self,
            Undo | Redo
                | EraseSelection
                | FillSelection
                | InvertSelection
                | SelectAll
                | Deselect
                | CropToSelection
                | FlipHorizontal
                | FlipVertical
                | Rotate90Cw
                | Rotate90Ccw
                | Rotate180
                | Flatten
                | AddLayer
                | DeleteLayer
                | DuplicateLayer
                | MergeLayerDown
                | FlipLayerHorizontal
                | FlipLayerVertical
                | MoveLayerUp
                | MoveLayerDown
        )
    }
}

/// `RotateNinetyCw` -> `rotate_ninety_cw`; digits stay with the word.
fn snake(name: &str) -> String {
    let mut out = String::new();
    for (i, c) in name.chars().enumerate() {
        if c.is_ascii_uppercase() {
            if i > 0 {
                out.push('_');
            }
            out.push(c.to_ascii_lowercase());
        } else {
            out.push(c);
        }
    }
    out
}

impl AdjustmentKind {
    pub fn id(self) -> String {
        snake(&format!("{self:?}"))
    }
}

impl EffectKind {
    /// Every effect, in the menu's order.
    pub const ALL: [EffectKind; 31] = {
        use EffectKind::*;
        [
            InkSketch,
            OilPainting,
            PencilSketch,
            Fragment,
            GaussianBlur,
            MotionBlur,
            RadialBlur,
            SurfaceBlur,
            Unfocus,
            ZoomBlur,
            Bulge,
            Dents,
            FrostedGlass,
            Pixelate,
            PolarInversion,
            TileReflection,
            Twist,
            AddNoise,
            Median,
            ReduceNoise,
            Glow,
            RedEyeRemoval,
            Sharpen,
            SoftenPortrait,
            Clouds,
            JuliaFractal,
            MandelbrotFractal,
            EdgeDetect,
            Emboss,
            Outline,
            Relief,
        ]
    };

    pub fn id(self) -> String {
        snake(&format!("{self:?}"))
    }
}

impl Document {
    /// Whether a command is enabled for this image: Paint.NET greys out
    /// what has nothing to act on. Commands that are not the image's
    /// (files, windows, the view) are enabled here; the shell decides.
    pub fn can_run(&self, command: Command) -> bool {
        use Command::*;
        let selected = self.selection().is_active();
        match command {
            Undo => self.can_undo(),
            Redo => self.can_redo(),
            Cut | Copy | EraseSelection | FillSelection | InvertSelection | Deselect
            | CropToSelection | ZoomToSelection => selected,
            DeleteLayer | Flatten => self.layers().len() > 1,
            MergeLayerDown | MoveLayerDown => self.active_layer_index() > 0,
            MoveLayerUp => self.active_layer_index() + 1 < self.layers().len(),
            _ => true,
        }
    }

    /// Carries out a command that needs only the image (see
    /// [`Command::is_document_command`]); `false` for any other.
    pub fn run(&mut self, command: Command) -> Result<bool> {
        use Command::*;
        match command {
            Undo => self.undo().map(drop),
            Redo => self.redo().map(drop),
            EraseSelection => self.erase_selection(),
            FillSelection => self.fill_selection(),
            InvertSelection => self.invert_selection(),
            SelectAll => self.select_all(),
            Deselect => self.deselect(),
            CropToSelection => self.crop_to_selection(),
            FlipHorizontal => self.flip_image(true),
            FlipVertical => self.flip_image(false),
            Rotate90Cw => self.rotate_image(1),
            Rotate90Ccw => self.rotate_image(3),
            Rotate180 => self.rotate_image(2),
            Flatten => self.flatten(),
            AddLayer => self.add_layer().map(drop),
            DeleteLayer => self.delete_layer(),
            DuplicateLayer => self.duplicate_layer().map(drop),
            MergeLayerDown => self.merge_layer_down(),
            FlipLayerHorizontal => self.flip_layer(true),
            FlipLayerVertical => self.flip_layer(false),
            MoveLayerUp => self.move_layer(true).map(drop),
            MoveLayerDown => self.move_layer(false).map(drop),
            _ => return Ok(false),
        }?;
        Ok(true)
    }
}

/// Every command that can have keys, for the key lookup.
const ALL: &[Command] = &{
    use Command::*;
    [
        New,
        Open,
        Close,
        Save,
        SaveAs,
        Exit,
        Undo,
        Redo,
        Cut,
        Copy,
        Paste,
        PasteIntoNewLayer,
        PasteIntoNewImage,
        EraseSelection,
        FillSelection,
        InvertSelection,
        SelectAll,
        Deselect,
        ZoomIn,
        ZoomOut,
        ZoomToWindow,
        ZoomToSelection,
        ActualSize,
        PixelGrid,
        CropToSelection,
        Resize,
        CanvasSize,
        FlipHorizontal,
        FlipVertical,
        Rotate90Cw,
        Rotate90Ccw,
        Rotate180,
        Flatten,
        AddLayer,
        DeleteLayer,
        DuplicateLayer,
        MergeLayerDown,
        ImportFromFile,
        FlipLayerHorizontal,
        FlipLayerVertical,
        MoveLayerUp,
        MoveLayerDown,
        LayerProperties,
        Adjust(AdjustmentKind::AutoLevel),
        Adjust(AdjustmentKind::BlackAndWhite),
        Adjust(AdjustmentKind::BrightnessContrast),
        Adjust(AdjustmentKind::Curves),
        Adjust(AdjustmentKind::HueSaturation),
        Adjust(AdjustmentKind::InvertColors),
        Adjust(AdjustmentKind::Levels),
        Adjust(AdjustmentKind::Posterize),
        Adjust(AdjustmentKind::Sepia),
        RepeatEffect,
        ToggleTools,
        ToggleHistory,
        ToggleLayers,
        ToggleColors,
        NextImage,
        PreviousImage,
        Help,
    ]
};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn keys_match_exactly() {
        assert_eq!(
            Command::for_shortcut(CTRL.0, CTRL.1, CTRL.2, "Z"),
            Some(Command::Undo)
        );
        assert_eq!(
            Command::for_shortcut(CTRL_SHIFT.0, CTRL_SHIFT.1, CTRL_SHIFT.2, "Z"),
            None
        );
        assert_eq!(
            Command::for_shortcut(CTRL_SHIFT.0, CTRL_SHIFT.1, CTRL_SHIFT.2, "N"),
            Some(Command::AddLayer)
        );
        assert_eq!(
            Command::for_shortcut(CTRL.0, CTRL.1, CTRL.2, "N"),
            Some(Command::New)
        );
        assert_eq!(
            Command::for_shortcut(NONE.0, NONE.1, NONE.2, "Delete"),
            Some(Command::EraseSelection)
        );
        assert_eq!(
            Command::for_shortcut(CTRL_SHIFT.0, CTRL_SHIFT.1, CTRL_SHIFT.2, "Delete"),
            Some(Command::DeleteLayer)
        );
        assert_eq!(
            Command::for_shortcut(CTRL_SHIFT.0, CTRL_SHIFT.1, CTRL_SHIFT.2, "L"),
            Some(Command::Adjust(AdjustmentKind::AutoLevel))
        );
    }

    #[test]
    fn no_two_commands_share_a_key() {
        let mut seen = std::collections::HashSet::new();
        for c in ALL
            .iter()
            .copied()
            .collect::<std::collections::HashSet<_>>()
        {
            for s in c.shortcuts() {
                assert!(seen.insert(*s), "{c:?} {s:?}");
            }
        }
    }

    #[test]
    fn shortcut_text_reads_like_the_menu() {
        assert_eq!(Command::SaveAs.shortcut_text(), "Ctrl+Shift+S");
        assert_eq!(Command::EraseSelection.shortcut_text(), "Del");
        assert_eq!(Command::ZoomIn.shortcut_text(), "Ctrl++");
    }

    #[test]
    fn ids_go_both_ways() {
        for &c in ALL {
            assert_eq!(Command::from_id(&c.id()), Some(c), "{}", c.id());
        }
        let blur = Command::Effect(EffectKind::GaussianBlur);
        assert_eq!(blur.id(), "effect:gaussian_blur");
        assert_eq!(Command::from_id("effect:gaussian_blur"), Some(blur));
        assert_eq!(Command::Rotate90Cw.id(), "rotate90_cw");
    }

    #[test]
    fn every_effect_has_its_kind_and_one_menu_place() {
        let mut in_menu: Vec<EffectKind> = EffectKind::MENU
            .iter()
            .flat_map(|(_, kinds)| kinds.iter().copied())
            .collect();
        assert_eq!(in_menu, EffectKind::ALL);
        in_menu.dedup();
        assert_eq!(in_menu.len(), EffectKind::ALL.len());
        for kind in EffectKind::ALL {
            assert_eq!(EffectKind::of(&kind.default_effect()), kind, "{kind:?}");
            let id = Command::Effect(kind).id();
            assert_eq!(Command::from_id(&id), Some(Command::Effect(kind)));
        }
        for (_, kinds) in EffectKind::MENU {
            let names: Vec<_> = kinds.iter().map(|k| k.name()).collect();
            assert!(names.windows(2).all(|w| w[0] < w[1]), "{names:?}");
        }
        assert_eq!(EffectKind::RedEyeRemoval.id(), "red_eye_removal");
    }

    #[test]
    fn the_document_runs_its_commands() {
        let mut doc = Document::new(8, 8, crate::color::Rgba8::WHITE).unwrap();
        assert!(!doc.can_run(Command::Undo));
        assert!(doc.run(Command::AddLayer).unwrap());
        assert!(doc.can_run(Command::Undo));
        assert!(doc.can_run(Command::MergeLayerDown));
        assert!(!doc.run(Command::Save).unwrap());
        assert_eq!(doc.layers().len(), 2);
    }
}
