import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:editor_ui/src/widgets/setting_glyph.dart';
import 'package:editor_ui/src/widgets/setting_icon_widget.dart';
import 'package:editor_ui/src/widgets/strip_controls.dart';
import 'package:editor_ui/src/widgets/tool_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The tool bar over the canvas: the active tool and the settings it
/// uses (shared between tools, as in Paint.NET).
class ToolBarComponent extends StatelessWidget {
  const ToolBarComponent({super.key});

  static const _brushes = {
    Tool.paintbrush,
    Tool.eraser,
    Tool.cloneStamp,
    Tool.recolor,
    Tool.lineCurve,
    Tool.rectangle,
    Tool.roundedRectangle,
    Tool.ellipse,
    Tool.freeformShape,
  };
  static const _shapes = {
    Tool.rectangle,
    Tool.roundedRectangle,
    Tool.ellipse,
    Tool.freeformShape,
  };
  static const _selections = {
    Tool.rectangleSelect,
    Tool.lassoSelect,
    Tool.ellipseSelect,
    Tool.magicWand,
  };
  static const _antialiased = {..._brushes, Tool.paintBucket, Tool.text};
  static const _blended = {
    Tool.paintbrush,
    Tool.pencil,
    Tool.paintBucket,
    Tool.gradient,
    Tool.lineCurve,
    Tool.rectangle,
    Tool.roundedRectangle,
    Tool.ellipse,
    Tool.freeformShape,
    Tool.text,
  };

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final bloc = context.read<EditorBloc>();
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.tool != b.tool ||
          a.toolSettings != b.toolSettings,
      builder: (context, state) {
        if (state is! EditorReady) {
          return const SizedBox(height: ControlSize.bar);
        }
        final tool = state.tool;
        final s = state.toolSettings;
        void set(ToolSettings next) => bloc.add(ToolSettingsChangedEvent(next));
        // Each group as Paint.NET 3.36's strip has it, apart by a line;
        // which settings are icons and which are named is the table in
        // behaviour.md.
        final groups = <List<Widget>>[
          if (_selections.contains(tool))
            [
              StripLabelWidget(words.settingSelectionMode),
              StripIconChoiceWidget<CombineMode>(
                value: s.selectionMode,
                values: CombineMode.values,
                icon: (m, on) =>
                    SettingIconWidget(SettingGlyph.combine(m), selected: on),
                label: (m) => words.combineMode(m.name),
                onChanged: (m) => set(s.copyWith(selectionMode: m)),
              ),
            ],
          if (tool == Tool.rectangleSelect)
            [
              StripLabelWidget(words.settingDrawMode),
              StripChoiceWidget<SelectDraw>(
                value: s.selectDraw,
                values: SelectDraw.values,
                icon: (d) => Icon(switch (d) {
                  SelectDraw.normal => Icons.crop_free_rounded,
                  SelectDraw.fixedRatio => Icons.aspect_ratio_rounded,
                  SelectDraw.fixedSize => Icons.photo_size_select_small,
                }, size: ControlSize.icon),
                label: (d) => switch (d) {
                  SelectDraw.normal => words.drawNormal,
                  SelectDraw.fixedRatio => words.drawFixedRatio,
                  SelectDraw.fixedSize => words.drawFixedSize,
                },
                onChanged: (d) => set(s.copyWith(selectDraw: d)),
              ),
              if (s.selectDraw != SelectDraw.normal) ...[
                StripLabelWidget(words.width),
                StripNumberWidget(
                  value: s.fixed.$1.round(),
                  min: 1,
                  max: 65535,
                  onChanged: (v) =>
                      set(s.copyWith(fixed: (v.toDouble(), s.fixed.$2))),
                ),
                BarButtonWidget(
                  size: ControlSize.field,
                  tooltip: words.settingSwapSize,
                  onPressed: () =>
                      set(s.copyWith(fixed: (s.fixed.$2, s.fixed.$1))),
                  child: const Icon(Icons.swap_horiz_rounded),
                ),
                StripLabelWidget(words.height),
                StripNumberWidget(
                  value: s.fixed.$2.round(),
                  min: 1,
                  max: 65535,
                  onChanged: (v) =>
                      set(s.copyWith(fixed: (s.fixed.$1, v.toDouble()))),
                ),
              ],
            ],
          if (tool == Tool.moveSelectedPixels)
            [
              StripLabelWidget(words.settingResampling),
              StripChoiceWidget<Resampling>(
                value: s.resampling,
                values: Resampling.values,
                label: (r) => r == Resampling.bilinear
                    ? words.resamplingBilinear
                    : words.resamplingNearest,
                onChanged: (r) => set(s.copyWith(resampling: r)),
              ),
            ],
          if (_shapes.contains(tool))
            [
              StripIconChoiceWidget<ShapeDraw>(
                value: s.shapeDraw,
                values: ShapeDraw.values,
                icon: (d, on) =>
                    SettingIconWidget(SettingGlyph.shape(d), selected: on),
                label: (d) => switch (d) {
                  ShapeDraw.outline => words.shapeOutline,
                  ShapeDraw.interior => words.shapeInterior,
                  ShapeDraw.both => words.shapeBoth,
                },
                onChanged: (d) => set(s.copyWith(shapeDraw: d)),
              ),
            ],
          if (_brushes.contains(tool))
            [
              StripLabelWidget(words.settingWidth),
              StripNumberWidget(
                value: s.width.round(),
                min: 1,
                max: 500,
                tooltip: '${words.settingWidth} ([ ])',
                onChanged: (v) => set(s.copyWith(width: v.toDouble())),
              ),
            ],
          if (tool == Tool.paintbrush || tool == Tool.eraser)
            [
              StripLabelWidget(words.settingHardness),
              StripPercentWidget(
                value: s.hardness,
                onChanged: (v) => set(s.copyWith(hardness: v)),
              ),
            ],
          if (tool == Tool.magicWand || tool == Tool.paintBucket)
            [
              StripLabelWidget(words.settingFloodMode),
              StripIconChoiceWidget<FloodMode>(
                value: s.floodMode,
                values: FloodMode.values,
                icon: (m, on) =>
                    SettingIconWidget(SettingGlyph.flood(m), selected: on),
                label: (m) =>
                    m == FloodMode.local ? words.floodLocal : words.floodGlobal,
                onChanged: (m) => set(s.copyWith(floodMode: m)),
              ),
            ],
          if (tool == Tool.magicWand ||
              tool == Tool.paintBucket ||
              tool == Tool.recolor)
            [
              StripLabelWidget(words.settingTolerance),
              StripPercentWidget(
                value: s.tolerance,
                onChanged: (v) => set(s.copyWith(tolerance: v)),
              ),
            ],
          if (tool == Tool.gradient) ...[
            [
              StripIconChoiceWidget<GradientKind>(
                value: s.gradient,
                values: GradientKind.values,
                icon: (k, on) =>
                    SettingIconWidget(SettingGlyph.gradient(k), selected: on),
                label: (k) => words.gradientKind(k.name),
                onChanged: (k) => set(s.copyWith(gradient: k)),
              ),
            ],
            [
              StripIconChoiceWidget<bool>(
                value: s.gradientTransparency,
                values: const [false, true],
                icon: (t, on) => SettingIconWidget(
                  t
                      ? SettingGlyph.gradientTransparency
                      : SettingGlyph.gradientColor,
                  selected: on,
                ),
                label: (t) =>
                    t ? words.gradientTransparency : words.gradientColor,
                onChanged: (t) => set(s.copyWith(gradientTransparency: t)),
              ),
            ],
          ],
          if (tool == Tool.lineCurve)
            [
              StripLabelWidget(words.settingLineStyle),
              StripIconMenuWidget<LineCap>(
                value: s.lineStart,
                values: LineCap.values,
                icon: (c) =>
                    SettingIconWidget(SettingGlyph.cap(c), mirrored: true),
                label: (c) => words.lineCap(c.name),
                tooltip: words.settingLineStart,
                onChanged: (c) => set(s.copyWith(lineStart: c)),
              ),
              StripIconMenuWidget<DashStyle>(
                value: s.dash,
                values: DashStyle.values,
                icon: (d) => SettingIconWidget(SettingGlyph.dash(d)),
                label: (d) => words.dashStyle(d.name),
                tooltip: words.settingDash,
                onChanged: (d) => set(s.copyWith(dash: d)),
              ),
              StripIconMenuWidget<LineCap>(
                value: s.lineEnd,
                values: LineCap.values,
                icon: (c) => SettingIconWidget(SettingGlyph.cap(c)),
                label: (c) => words.lineCap(c.name),
                tooltip: words.settingLineEnd,
                onChanged: (c) => set(s.copyWith(lineEnd: c)),
              ),
            ],
          if (tool == Tool.text) ...[
            [
              StripLabelWidget(words.settingFont),
              _FontChoice(
                font: s.font,
                onChanged: (f) => set(s.copyWith(font: f)),
              ),
              StripNumberWidget(
                value: s.fontSize.round(),
                min: 1,
                max: 2000,
                tooltip: words.settingFontSize,
                onChanged: (v) => set(s.copyWith(fontSize: v.toDouble())),
              ),
            ],
            [
              for (final (on, icon, tooltip, apply) in [
                (
                  s.bold,
                  Icons.format_bold_rounded,
                  words.textBold,
                  (bool v) => s.copyWith(bold: v),
                ),
                (
                  s.italic,
                  Icons.format_italic_rounded,
                  words.textItalic,
                  (bool v) => s.copyWith(italic: v),
                ),
                (
                  s.underline,
                  Icons.format_underlined_rounded,
                  words.textUnderline,
                  (bool v) => s.copyWith(underline: v),
                ),
                (
                  s.strikeout,
                  Icons.format_strikethrough_rounded,
                  words.textStrikeout,
                  (bool v) => s.copyWith(strikeout: v),
                ),
              ])
                StripIconToggleWidget(
                  value: on,
                  icon: Icon(icon),
                  tooltip: tooltip,
                  onChanged: (v) => set(apply(v)),
                ),
            ],
            [
              StripIconChoiceWidget<PaintTextAlign>(
                value: s.textAlign,
                values: PaintTextAlign.values,
                icon: (a, _) => Icon(switch (a) {
                  PaintTextAlign.left => Icons.format_align_left_rounded,
                  PaintTextAlign.center => Icons.format_align_center_rounded,
                  PaintTextAlign.right => Icons.format_align_right_rounded,
                }),
                label: (a) => words.textAlign(a.name),
                onChanged: (a) => set(s.copyWith(textAlign: a)),
              ),
            ],
          ],
          if (tool == Tool.colorPicker)
            [
              StripLabelWidget(words.settingAfterPick),
              StripChoiceWidget<PickerAfter>(
                value: s.pickerAfter,
                values: PickerAfter.values,
                label: (a) => switch (a) {
                  PickerAfter.stay => words.pickStay,
                  PickerAfter.previousTool => words.pickPrevious,
                  PickerAfter.pencil => words.pickPencil,
                },
                onChanged: (a) => set(s.copyWith(pickerAfter: a)),
              ),
            ],
          if (_antialiased.contains(tool) || _blended.contains(tool))
            [
              if (_antialiased.contains(tool))
                StripIconToggleWidget(
                  value: s.antialias,
                  icon: SettingIconWidget(
                    s.antialias
                        ? SettingGlyph.antialiasOn
                        : SettingGlyph.antialiasOff,
                    selected: s.antialias,
                  ),
                  tooltip: words.settingAntialias,
                  onChanged: (v) => set(s.copyWith(antialias: v)),
                ),
              if (_blended.contains(tool))
                StripIconToggleWidget(
                  value: s.alphaBlending,
                  icon: SettingIconWidget(
                    s.alphaBlending
                        ? SettingGlyph.blendingOn
                        : SettingGlyph.blendingOff,
                    selected: s.alphaBlending,
                  ),
                  tooltip: words.settingAlphaBlending,
                  onChanged: (v) => set(s.copyWith(alphaBlending: v)),
                ),
            ],
        ];
        return SizedBox(
          height: ControlSize.bar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.xs),
            child: Row(
              children: [
                // In a button's box, on the commands' grid.
                SizedBox.square(
                  dimension: ControlSize.button,
                  child: Center(child: ToolIconWidget(tool: tool, size: 16)),
                ),
                Text(
                  words.tool(tool),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: groups.isEmpty
                        ? Text(
                            words.settingNone,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: context.tokens.muted),
                          )
                        : Row(
                            children: [
                              for (final (i, group) in groups.indexed) ...[
                                if (i > 0)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Space.xs,
                                      vertical: Space.xs,
                                    ),
                                    child: Hairline(vertical: true),
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: Space.xxs,
                                  children: group,
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The font box: the core's fonts once scanned; an empty name is the
/// built-in font, listed first.
class _FontChoice extends StatelessWidget {
  const _FontChoice({required this.font, required this.onChanged});

  final String font;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
    future: PaintCatalog.fonts,
    builder: (context, snapshot) {
      final fonts = snapshot.data ?? const <String>[];
      final builtIn = fonts.isEmpty ? '' : fonts.first;
      final shown = font.isEmpty ? builtIn : font;
      return StripChoiceWidget<String>(
        value: shown,
        values: fonts.isEmpty ? [shown] : fonts,
        label: (f) => f,
        onChanged: (f) => onChanged(f == builtIn ? '' : f),
      );
    },
  );
}
