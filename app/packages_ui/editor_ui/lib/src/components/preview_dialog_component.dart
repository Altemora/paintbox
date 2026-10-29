import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/curves_editor_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:editor_ui/src/widgets/strip_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The open previewing dialog (an adjustment, an effect, Layer
/// Properties) floating at the top of the canvas: it does not dim
/// the image, which shows the result live. While it is open the canvas,
/// tools and history wait; Enter is OK, Esc Cancel.
class PreviewDialogComponent extends StatelessWidget {
  const PreviewDialogComponent({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<EditorBloc, EditorState, PreviewInfo?>(
        selector: (state) => state is EditorReady ? state.preview : null,
        builder: (context, preview) => AnimatedSwitcher(
          duration: Motion.normal,
          switchInCurve: Motion.curve,
          child: preview == null
              ? const SizedBox.shrink()
              : Align(
                  key: ValueKey(preview.id),
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(Space.md),
                    child: _DialogWidget(preview: preview),
                  ),
                ),
        ),
      );
}

class _DialogWidget extends StatelessWidget {
  const _DialogWidget({required this.preview});

  final PreviewInfo preview;

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final bloc = context.read<EditorBloc>();
    final busy = preview.rendering || preview.finishing;
    final layer = preview.layer;
    return SizedBox(
      width: 340,
      child: GlassPanel(
        strong: true,
        shadow: true,
        radius: Radii.sm,
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              words.dialog(preview.id),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Space.sm),
            if (preview.curves case final curves?)
              CurvesEditorWidget(
                curves: curves,
                luminosityLabel: words.paramName('brightness'),
                onChanged: (c) => bloc.add(CurvesChangedEvent(c)),
              ),
            if (layer != null)
              _LayerControls(
                properties: layer,
                onChanged: (p) => bloc.add(LayerPreviewChangedEvent(p)),
              ),
            if (!preview.repeat)
              for (final param in preview.params)
                _ParamControl(
                  param: param,
                  label: words.param(param.name),
                  reseed: words.reseed,
                  onChanged: (values) =>
                      bloc.add(PreviewParamChangedEvent(param.name, values)),
                ),
            const SizedBox(height: Space.xs),
            AnimatedOpacity(
              duration: Motion.fast,
              opacity: busy ? 1 : 0,
              child: const LinearProgressIndicator(minHeight: 2),
            ),
            const SizedBox(height: Space.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => bloc.add(const PreviewEndedEvent(ok: false)),
                  child: Text(words.cancel),
                ),
                const SizedBox(width: Space.xs),
                FilledButton(
                  onPressed: preview.finishing
                      ? null
                      : () => bloc.add(const PreviewEndedEvent(ok: true)),
                  child: Text(words.ok),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ParamControl extends StatelessWidget {
  const _ParamControl({
    required this.param,
    required this.label,
    required this.reseed,
    required this.onChanged,
  });

  final DialogParam param;
  final String label;
  final String reseed;
  final ValueChanged<List<double>> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodySmall;
    final value = param.values.isEmpty ? 0.0 : param.values.first;
    // Levels keeps a value per channel; the dialog moves them together.
    List<double> all(double v) => List.filled(param.values.length, v);
    switch (param.kind) {
      case ParamKind.flag:
        return CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: value != 0,
          onChanged: (v) => onChanged(all(v == true ? 1 : 0)),
          title: Text(label, style: text),
        );
      case ParamKind.seed:
        return Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () =>
                onChanged(all(math.Random().nextInt(1 << 31).toDouble())),
            icon: const Icon(Icons.casino_outlined, size: 16),
            label: Text(reseed),
          ),
        );
      case ParamKind.integer || ParamKind.real:
        final integer = param.kind == ParamKind.integer;
        return Padding(
          padding: const EdgeInsets.only(bottom: Space.xxs),
          child: Row(
            children: [
              SizedBox(width: 108, child: Text(label, style: text)),
              Expanded(
                child: Slider(
                  value: value.clamp(param.min, param.max),
                  min: param.min,
                  max: param.max,
                  divisions: integer
                      ? (param.max - param.min).round().clamp(1, 1000)
                      : null,
                  onChanged: (v) =>
                      onChanged(all(integer ? v.roundToDouble() : _two(v))),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  integer ? value.round().toString() : value.toStringAsFixed(2),
                  textAlign: TextAlign.end,
                  style: text,
                ),
              ),
            ],
          ),
        );
    }
  }

  static double _two(double v) => (v * 100).roundToDouble() / 100;
}

class _LayerControls extends StatelessWidget {
  const _LayerControls({required this.properties, required this.onChanged});

  final LayerProperties properties;
  final ValueChanged<LayerProperties> onChanged;

  LayerProperties _with({
    String? name,
    bool? visible,
    int? opacity,
    BlendMode? blendMode,
  }) => LayerProperties(
    name: name ?? properties.name,
    visible: visible ?? properties.visible,
    opacity: opacity ?? properties.opacity,
    blendMode: blendMode ?? properties.blendMode,
    isBackground: properties.isBackground,
  );

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme.bodySmall;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NameField(
          label: words.layerName,
          name: properties.name,
          onChanged: (name) => onChanged(_with(name: name)),
        ),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: properties.visible,
          onChanged: (v) => onChanged(_with(visible: v ?? true)),
          title: Text(words.layerVisible, style: text),
        ),
        Row(
          children: [
            SizedBox(
              width: 108,
              child: Text(words.layerBlendMode, style: text),
            ),
            StripChoiceWidget<BlendMode>(
              value: properties.blendMode,
              values: BlendMode.values,
              label: words.blendMode,
              onChanged: (m) => onChanged(_with(blendMode: m)),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 108, child: Text(words.layerOpacity, style: text)),
            Expanded(
              child: Slider(
                value: properties.opacity.toDouble(),
                max: 255,
                divisions: 255,
                onChanged: (v) => onChanged(_with(opacity: v.round())),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '${properties.opacity}',
                textAlign: TextAlign.end,
                style: text,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NameField extends StatefulWidget {
  const _NameField({
    required this.label,
    required this.name,
    required this.onChanged,
  });

  final String label;
  final String name;
  final ValueChanged<String> onChanged;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    style: Theme.of(context).textTheme.bodyMedium,
    decoration: InputDecoration(labelText: widget.label),
    onChanged: widget.onChanged,
  );
}
