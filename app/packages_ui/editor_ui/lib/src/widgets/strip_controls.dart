import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A label before a control of the tool bar.
class StripLabelWidget extends StatelessWidget {
  const StripLabelWidget(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: context.tokens.muted),
  );
}

/// A whole number with − and + buttons and a field.
class StripNumberWidget extends StatefulWidget {
  const StripNumberWidget({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.tooltip,
    super.key,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? tooltip;

  @override
  State<StripNumberWidget> createState() => _StripNumberWidgetState();
}

class _StripNumberWidgetState extends State<StripNumberWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.value}',
  );
  final FocusNode _focus = FocusNode();

  @override
  void didUpdateWidget(StripNumberWidget old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _controller.text != '${widget.value}') {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final v = int.tryParse(_controller.text);
    if (v != null) {
      widget.onChanged(v.clamp(widget.min, widget.max));
    } else {
      _controller.text = '${widget.value}';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget step(IconData icon, int delta) => BarButtonWidget(
      tooltip: null,
      size: ControlSize.field,
      onPressed: () => widget.onChanged(
        (widget.value + delta).clamp(widget.min, widget.max),
      ),
      child: Icon(icon, size: 14),
    );
    final field = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        step(Icons.remove_rounded, -1),
        SizedBox(
          width: 40,
          height: ControlSize.field,
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _submit(),
            onTapOutside: (_) {
              _submit();
              _focus.unfocus();
            },
          ),
        ),
        step(Icons.add_rounded, 1),
      ],
    );
    return widget.tooltip == null
        ? field
        : Tooltip(message: widget.tooltip, child: field);
  }
}

/// A 0 – 100 % slider with its value.
class StripPercentWidget extends StatelessWidget {
  const StripPercentWidget({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// 0 – 1.
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 120,
        height: ControlSize.field,
        child: Slider(value: value.clamp(0, 1), onChanged: onChanged),
      ),
      SizedBox(
        width: 40,
        child: Text(
          '${(value * 100).round()} %',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}

/// A few values that a picture tells apart, as a row of icon buttons
/// with the chosen one lit (Paint.NET's gradient types, alignment).
class StripIconChoiceWidget<T> extends StatelessWidget {
  const StripIconChoiceWidget({
    required this.value,
    required this.values,
    required this.icon,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final T value;
  final List<T> values;

  /// The picture of a value, lit when it is the chosen one.
  final Widget Function(T value, bool selected) icon;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 1,
    children: [
      for (final v in values)
        BarButtonWidget(
          size: ControlSize.field,
          iconSize: ControlSize.settingIcon,
          tooltip: label(v),
          selected: v == value,
          onPressed: () => onChanged(v),
          child: icon(v, v == value),
        ),
    ],
  );
}

/// On or off as one icon button, lit when on (bold, antialiasing).
class StripIconToggleWidget extends StatelessWidget {
  const StripIconToggleWidget({
    required this.value,
    required this.icon,
    required this.tooltip,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final Widget icon;
  final String tooltip;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => BarButtonWidget(
    size: ControlSize.field,
    iconSize: ControlSize.settingIcon,
    tooltip: tooltip,
    selected: value,
    onPressed: () => onChanged(!value),
    child: icon,
  );
}

/// One of a few values shown by its picture, the others in a menu with
/// pictures and names: Paint.NET's split buttons, where a row of all the
/// pictures would crowd the bar (line ends and dashes).
class StripIconMenuWidget<T> extends StatelessWidget {
  const StripIconMenuWidget({
    required this.value,
    required this.values,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onChanged,
    super.key,
  });

  final T value;
  final List<T> values;
  final Widget Function(T value) icon;
  final String Function(T value) label;
  final String tooltip;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => MenuAnchor(
    menuChildren: [
      for (final v in values)
        MenuItemButton(
          leadingIcon: SizedBox(
            width: ControlSize.icon,
            child: v == value
                ? const Icon(Icons.check_rounded, size: 14)
                : null,
          ),
          trailingIcon: IconTheme.merge(
            data: const IconThemeData(size: ControlSize.settingIcon),
            child: icon(v),
          ),
          onPressed: () => onChanged(v),
          child: Text(label(v)),
        ),
    ],
    builder: (context, controller, _) => GlassTap(
      tooltip: '$tooltip: ${label(value)}',
      onTap: () => controller.isOpen ? controller.close() : controller.open(),
      padding: const EdgeInsets.only(left: Space.xxs),
      child: SizedBox(
        height: ControlSize.field,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme.merge(
              data: IconThemeData(
                size: ControlSize.settingIcon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              child: icon(value),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 14,
              color: context.tokens.muted,
            ),
          ],
        ),
      ),
    ),
  );
}

/// One of many values, or values a picture would not tell apart, as the
/// chosen one's name in a menu (fonts, resampling); [icon] puts a picture
/// before the name, as Paint.NET's image-and-text buttons have.
class StripChoiceWidget<T> extends StatelessWidget {
  const StripChoiceWidget({
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
    this.icon,
    super.key,
  });

  final T value;
  final List<T> values;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;
  final Widget Function(T value)? icon;

  @override
  Widget build(BuildContext context) => MenuAnchor(
    menuChildren: [
      for (final v in values)
        MenuItemButton(
          leadingIcon: SizedBox(
            width: ControlSize.icon,
            child: v == value
                ? const Icon(Icons.check_rounded, size: 14)
                : null,
          ),
          trailingIcon: icon?.call(v),
          onPressed: () => onChanged(v),
          child: Text(label(v)),
        ),
    ],
    builder: (context, controller, _) => GlassTap(
      onTap: () => controller.isOpen ? controller.close() : controller.open(),
      padding: const EdgeInsets.symmetric(horizontal: Space.xs),
      child: SizedBox(
        height: ControlSize.field,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Space.xxs,
          children: [
            ?icon?.call(value),
            Text(label(value), style: Theme.of(context).textTheme.bodySmall),
            Icon(
              Icons.expand_more_rounded,
              size: 14,
              color: context.tokens.muted,
            ),
          ],
        ),
      ),
    ),
  );
}
