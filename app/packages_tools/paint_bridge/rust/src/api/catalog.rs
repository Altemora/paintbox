//! What the shell lists and looks up without an image: tools, commands
//! with their keys, the Effects menu, the tool bar's settings and the
//! palette.

use flutter_rust_bridge::frb;
use paintbox_core as pb;

use crate::api::types::{
    CombineMode, CommandInfo, EffectGroup, FilterInfo, PaintResult, Rgba8, Tool, ToolInfo,
    ToolSettings,
};

/// Every tool in the Tools window's order.
#[frb(sync)]
pub fn tools() -> Vec<ToolInfo> {
    pb::Tool::ALL
        .iter()
        .map(|&tool| ToolInfo {
            tool,
            name: tool.name().to_owned(),
            key: tool.key().to_string(),
            hint: tool.hint().to_owned(),
            available: tool.is_available(),
        })
        .collect()
}

#[frb(sync)]
pub fn tool_id(tool: Tool) -> String {
    tool.id().to_owned()
}

#[frb(sync)]
pub fn tool_from_id(id: String) -> Option<Tool> {
    pb::Tool::from_id(&id)
}

/// Every command with a menu item or keys.
#[frb(sync)]
pub fn commands() -> Vec<CommandInfo> {
    pb::Command::all()
        .iter()
        .map(|&command| CommandInfo {
            id: command.id(),
            label: command.label().to_owned(),
            shortcut: command.shortcut_text(),
        })
        .collect()
}

/// The command a key runs: modifiers match exactly, `key` as the core
/// names keys (`Z`, `Delete`, `Plus`, `Equals`, `F4`, `Tab`).
#[frb(sync)]
pub fn command_for_key(ctrl: bool, shift: bool, alt: bool, key: String) -> Option<String> {
    pb::Command::for_shortcut(ctrl, shift, alt, &key).map(pb::Command::id)
}

/// The Adjustments menu in order.
#[frb(sync)]
pub fn adjustments() -> Vec<FilterInfo> {
    pb::AdjustmentKind::ALL
        .iter()
        .map(|&kind| {
            let command = pb::Command::Adjust(kind);
            FilterInfo {
                id: command.id(),
                name: command.label().trim_end_matches("...").to_owned(),
                dialog: !kind.is_immediate(),
            }
        })
        .collect()
}

/// The Effects menu's submenus as Paint.NET groups them.
#[frb(sync)]
pub fn effect_menu() -> Vec<EffectGroup> {
    pb::EffectKind::MENU
        .iter()
        .map(|(name, kinds)| EffectGroup {
            name: (*name).to_owned(),
            ids: kinds.iter().map(|&k| pb::Command::Effect(k).id()).collect(),
        })
        .collect()
}

#[frb(sync)]
pub fn default_tool_settings() -> ToolSettings {
    pb::ToolSettings::default()
}

/// Settings read back from storage, kept in their ranges.
#[frb(sync)]
pub fn sanitize_tool_settings(settings: ToolSettings) -> ToolSettings {
    settings.sanitized()
}

/// Line / Curve's `,` `.` `/`: the settings with the start, the dash or
/// the end moved to the next; none for another key.
#[frb(sync)]
pub fn cycle_line_setting(settings: ToolSettings, key: String) -> Option<ToolSettings> {
    let mut settings = settings;
    let c = key.chars().next()?;
    settings.cycle_line(c).then_some(settings)
}

/// The Text tool's fonts: the built-in one first, then the system's by
/// family name. The first call scans the font folders (on a worker).
pub fn font_names() -> Vec<String> {
    paintbox_core::text::font_names()
}

/// `[` and `]`: the width by one pixel, five with Ctrl.
#[frb(sync)]
pub fn step_tool_width(settings: ToolSettings, grow: bool, ctrl: bool) -> ToolSettings {
    let mut settings = settings;
    settings.step_width(grow, ctrl);
    settings
}

/// The order the tool bar's selection mode button cycles through.
#[frb(sync)]
pub fn selection_mode_cycle() -> Vec<CombineMode> {
    pb::CombineMode::CYCLE.to_vec()
}

/// Paint.NET's 96 swatches.
#[frb(sync)]
pub fn default_palette() -> Vec<Rgba8> {
    pb::Palette::default().colors().to_vec()
}

/// A palette file (`AARRGGBB` per line, `;` comments), as 96 colours.
#[frb(sync)]
pub fn parse_palette(text: String) -> PaintResult<Vec<Rgba8>> {
    Ok(pb::Palette::parse(&text)?.colors().to_vec())
}

#[frb(sync)]
pub fn palette_text(colors: Vec<Rgba8>) -> PaintResult<String> {
    let mut palette = pb::Palette::default();
    for (i, &color) in colors.iter().enumerate().take(palette.colors().len()) {
        palette.set(i, color)?;
    }
    Ok(palette.to_text())
}

/// Picks tools by letter: `s`, `m`, `o` cycle the tools sharing it
/// within two seconds, Shift going back.
#[frb(opaque)]
#[derive(Default)]
pub struct ToolKeys {
    cycle: pb::KeyCycle,
}

impl ToolKeys {
    #[frb(sync)]
    pub fn create() -> ToolKeys {
        ToolKeys::default()
    }

    /// The tool a letter selects, if any; `now` in seconds.
    #[frb(sync)]
    pub fn press(&mut self, letter: String, shift: bool, now: f64, current: Tool) -> Option<Tool> {
        let c = letter.chars().next()?;
        self.cycle
            .press(c, shift, if now.is_finite() { now } else { 0.0 }, current)
            .filter(|t| t.is_available())
    }
}

#[frb(init)]
pub fn init_bridge() {
    flutter_rust_bridge::setup_default_user_utils();
}

/// The curve through control points as the Curves adjustment applies it:
/// the output for every input 0 – 255, for the dialog to draw.
#[frb(sync)]
pub fn curve_table(points: Vec<(u8, u8)>) -> PaintResult<Vec<u8>> {
    Ok(pb::adjust::spline_table(&points)?.to_vec())
}

/// Every effect with its name, for the words of History steps.
#[frb(sync)]
pub fn effects() -> Vec<FilterInfo> {
    pb::EffectKind::ALL
        .iter()
        .map(|&kind| FilterInfo {
            id: pb::Command::Effect(kind).id(),
            name: kind.name().to_owned(),
            dialog: true,
        })
        .collect()
}
