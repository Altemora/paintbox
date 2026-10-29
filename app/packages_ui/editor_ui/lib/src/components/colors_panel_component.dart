import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/color_editor_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The Colors window: the primary and the secondary colour (a click
/// chooses which one the editor below changes, C does too), swap and
// black-and-white buttons, More / Less and the editor; under it the
/// palette: all 96 swatches with More, two rows of eight with Less, as
/// wide as the wheel.
class ColorsPanelComponent extends StatelessWidget {
  const ColorsPanelComponent({super.key});

  /// With More, the sliders beside the wheel; with Less, nothing is wider
  /// than the wheel.
  static const double _moreWidth = 360;
  static const double _lessWidth = ColorEditorWidget.wheelSize;
  static const int _lessColumns = 8;

  /// Less shows sixteen of the 96: black, white and greys and the hue
  /// circle bright and deep, picked from the default palette's first
  /// two rows (the first sixteen alone would have no white).
  static const _lessSwatches = [
    0, 1, 2, 3, 4, 6, 9, 11, //
    16, 17, 13, 14, 10, 8, 19, 15,
  ];

  static const _black = Rgba8(r: 0, g: 0, b: 0, a: 255);
  static const _white = Rgba8(r: 255, g: 255, b: 255, a: 255);

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final bloc = context.read<EditorBloc>();
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.colors != b.colors ||
          a.editsSecondary != b.editsSecondary ||
          a.palette != b.palette ||
          a.panels.colorsMore != b.panels.colorsMore,
      builder: (context, state) {
        if (state is! EditorReady) {
          return const SizedBox.shrink();
        }
        final colors = state.colors;
        final more = state.panels.colorsMore;
        final edited = state.editsSecondary ? colors.secondary : colors.primary;
        void set(Rgba8 color) => bloc.add(
          ColorsChangedEvent(
            state.editsSecondary
                ? UserColors(primary: colors.primary, secondary: color)
                : UserColors(primary: color, secondary: colors.secondary),
          ),
        );
        void pick(Rgba8 swatch, {required bool secondary}) => bloc.add(
          ColorsChangedEvent(
            secondary
                ? UserColors(primary: colors.primary, secondary: swatch)
                : UserColors(primary: swatch, secondary: colors.secondary),
          ),
        );
        // A click takes the swatch as primary, a right click as secondary;
        // dragged, it goes to whichever of the two it is dropped on.
        Widget swatchOf(Rgba8 swatch, {double? size}) => Draggable<Rgba8>(
          data: swatch,
          feedback: _SwatchFeedbackWidget(swatch),
          child: GestureDetector(
            onTap: () => pick(swatch, secondary: false),
            onSecondaryTap: () => pick(swatch, secondary: true),
            child: Container(
              width: size ?? ControlSize.swatch,
              height: size ?? ControlSize.swatch,
              color: swatch.color,
            ),
          ),
        );
        // Each mode is laid out at its own width; the window grows and
        // shrinks between them, clipping.
        return AnimatedSize(
          duration: Motion.normal,
          curve: Motion.curve,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: more ? _moreWidth : _lessWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Over the wheel, as Paint.NET has them: the two colours,
                // swap, black and white, more or less.
                ColorEditorWidget(
                  color: edited,
                  expanded: more,
                  onChanged: set,
                  leading: SizedBox(
                    width: ColorEditorWidget.wheelSize,
                    child: Row(
                      children: [
                        _PairWidget(
                          primary: colors.primary,
                          secondary: colors.secondary,
                          editsSecondary: state.editsSecondary,
                          primaryHint: words.colorsPrimaryHint,
                          secondaryHint: words.colorsSecondaryHint,
                          onChoose: (secondary) => bloc.add(
                            EditedColorChosenEvent(secondary: secondary),
                          ),
                          onDropped: pick,
                        ),
                        const Spacer(),
                        BarButtonWidget(
                          size: ControlSize.field,
                          tooltip: words.colorsSwap,
                          onPressed: () => bloc.add(
                            ColorsChangedEvent(
                              UserColors(
                                primary: colors.secondary,
                                secondary: colors.primary,
                              ),
                            ),
                          ),
                          child: const Icon(Icons.swap_horiz_outlined),
                        ),
                        BarButtonWidget(
                          size: ControlSize.field,
                          tooltip: words.colorsReset,
                          onPressed: () => bloc.add(
                            const ColorsChangedEvent(
                              UserColors(primary: _black, secondary: _white),
                            ),
                          ),
                          child: const Icon(Icons.invert_colors_outlined),
                        ),
                        BarButtonWidget(
                          size: ControlSize.field,
                          tooltip: more ? words.colorsLess : words.colorsMore,
                          onPressed: () =>
                              bloc.add(const ColorsMoreToggledEvent()),
                          child: Icon(
                            more
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  labels: ColorEditorLabels(
                    hue: words.colorsHue,
                    saturation: words.colorsSat,
                    value: words.colorsValue,
                    red: words.colorsRed,
                    green: words.colorsGreen,
                    blue: words.colorsBlue,
                    alpha: 'A',
                    hex: '#',
                    opacity: words.layerOpacity,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Tooltip(
                  message: words.colorsPaletteHint,
                  waitDuration: const Duration(seconds: 1),
                  child: more
                      ? Wrap(
                          spacing: 1,
                          runSpacing: 1,
                          children: [
                            for (final swatch in state.palette)
                              swatchOf(swatch),
                          ],
                        )
                      : _CompactPaletteWidget(
                          swatches: [
                            for (final i in _lessSwatches)
                              if (i < state.palette.length)
                                swatchOf(
                                  state.palette[i],
                                  size: double.infinity,
                                ),
                          ],
                          columns: _lessColumns,
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

/// The two colours as overlapping squares, the edited one in front.
class _PairWidget extends StatelessWidget {
  const _PairWidget({
    required this.primary,
    required this.secondary,
    required this.editsSecondary,
    required this.primaryHint,
    required this.secondaryHint,
    required this.onChoose,
    required this.onDropped,
  });

  final Rgba8 primary;
  final Rgba8 secondary;
  final bool editsSecondary;
  final String primaryHint;
  final String secondaryHint;
  final ValueChanged<bool> onChoose;

  /// A palette swatch dropped on one of the two.
  final void Function(Rgba8 color, {required bool secondary}) onDropped;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accent = Theme.of(context).colorScheme.primary;
    Widget square(Rgba8 color, bool active, String hint, bool secondary) =>
        DragTarget<Rgba8>(
          onAcceptWithDetails: (d) => onDropped(d.data, secondary: secondary),
          builder: (context, candidates, _) {
            final over = candidates.isNotEmpty;
            return Tooltip(
              message: hint,
              child: GestureDetector(
                onTap: () => onChoose(secondary),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: (over ? candidates.first! : color).color,
                    borderRadius: BorderRadius.circular(Space.xxs),
                    border: Border.all(
                      color: active || over ? accent : tokens.hairlineStrong,
                      width: active || over ? 2 : 1,
                    ),
                  ),
                ),
              ),
            );
          },
        );
    final back = square(secondary, editsSecondary, secondaryHint, true);
    final front = square(primary, !editsSecondary, primaryHint, false);
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        children: [
          Positioned(right: 0, bottom: 0, child: back),
          Positioned(left: 0, top: 0, child: front),
        ],
      ),
    );
  }
}

/// Rows of square swatches that share the width exactly.
class _CompactPaletteWidget extends StatelessWidget {
  const _CompactPaletteWidget({required this.swatches, required this.columns});

  final List<Widget> swatches;
  final int columns;

  @override
  Widget build(BuildContext context) => Column(
    spacing: 1,
    children: [
      for (var row = 0; row * columns < swatches.length; row++)
        Row(
          spacing: 1,
          children: [
            for (final swatch in swatches.skip(row * columns).take(columns))
              Expanded(child: AspectRatio(aspectRatio: 1, child: swatch)),
          ],
        ),
    ],
  );
}

/// A swatch under the pointer while it is dragged to the two colours.
class _SwatchFeedbackWidget extends StatelessWidget {
  const _SwatchFeedbackWidget(this.color);

  final Rgba8 color;

  @override
  Widget build(BuildContext context) => Container(
    width: 2 * ControlSize.swatch,
    height: 2 * ControlSize.swatch,
    decoration: BoxDecoration(
      color: color.color,
      borderRadius: BorderRadius.circular(Radii.xxs),
      border: Border.all(color: context.tokens.hairlineStrong),
      boxShadow: [BoxShadow(color: context.tokens.shadow, blurRadius: 8)],
    ),
  );
}
