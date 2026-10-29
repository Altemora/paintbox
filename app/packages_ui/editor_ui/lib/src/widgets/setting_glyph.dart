import 'package:paint_logic/paint_logic.dart';

/// The pictures of the tool bar's settings, drawn the way the tool icons
/// are (thin lines on a 24 × 24 grid), the part a setting changes in the
/// accent.
enum SettingGlyph {
  combineReplace,
  combineUnion,
  combineExclude,
  combineXor,
  combineIntersect,
  floodLocal,
  floodGlobal,
  shapeOutline,
  shapeInterior,
  shapeBoth,
  antialiasOn,
  antialiasOff,
  blendingOn,
  blendingOff,
  gradientLinear,
  gradientReflected,
  gradientDiamond,
  gradientRadial,
  gradientConical,
  gradientColor,
  gradientTransparency,
  capFlat,
  capArrow,
  capArrowFilled,
  capRounded,
  dashSolid,
  dashDash,
  dashDashDot,
  dashDashDotDot,
  dashDot;

  static SettingGlyph combine(CombineMode mode) => switch (mode) {
    CombineMode.replace => combineReplace,
    CombineMode.union => combineUnion,
    CombineMode.exclude => combineExclude,
    CombineMode.xor => combineXor,
    CombineMode.intersect => combineIntersect,
  };

  static SettingGlyph flood(FloodMode mode) =>
      mode == FloodMode.local ? floodLocal : floodGlobal;

  static SettingGlyph shape(ShapeDraw draw) => switch (draw) {
    ShapeDraw.outline => shapeOutline,
    ShapeDraw.interior => shapeInterior,
    ShapeDraw.both => shapeBoth,
  };

  static SettingGlyph gradient(GradientKind kind) => switch (kind) {
    GradientKind.linear => gradientLinear,
    GradientKind.linearReflected => gradientReflected,
    GradientKind.diamond => gradientDiamond,
    GradientKind.radial => gradientRadial,
    GradientKind.conical => gradientConical,
  };

  static SettingGlyph cap(LineCap cap) => switch (cap) {
    LineCap.flat => capFlat,
    LineCap.arrow => capArrow,
    LineCap.arrowFilled => capArrowFilled,
    LineCap.rounded => capRounded,
  };

  static SettingGlyph dash(DashStyle style) => switch (style) {
    DashStyle.solid => dashSolid,
    DashStyle.dash => dashDash,
    DashStyle.dashDot => dashDashDot,
    DashStyle.dashDotDot => dashDashDotDot,
    DashStyle.dot => dashDot,
  };
}
