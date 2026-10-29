import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:editor_ui/src/widgets/pixel_block_image_widget.dart';
import 'package:editor_ui/src/widgets/reorder_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The open images as tabs: the thumbnail with the name under it, a dot
/// for unsaved changes and a close button on the thumbnail's corner. A
/// tab dragged along the strip changes the order; after the tabs, as in
/// Paint.NET 5, a button lists the images and steps between them.
class ImageTabsComponent extends StatelessWidget {
  const ImageTabsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final bloc = context.read<EditorBloc>();
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.tabs != b.tabs ||
          a.activeId != b.activeId,
      builder: (context, state) {
        final tabs = state is EditorReady ? state.tabs : const <ImageTab>[];
        final active = state is EditorReady ? state.activeId : null;
        return Row(
          children: [
            Flexible(
              child: ReorderListWidget(
                axis: Axis.horizontal,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: Space.xxs),
                onMove: (from, to) =>
                    bloc.add(TabMovedEvent(tabs[from].id, to)),
                itemCount: tabs.length,
                itemBuilder: (context, i) {
                  final tab = tabs[i];
                  return _TabWidget(
                    name: words.title(tab.title),
                    thumbnail: tab.thumbnail,
                    isModified: tab.isModified,
                    selected: tab.id == active,
                    closeTooltip: words.command('close'),
                    onSelect: () => bloc.add(TabSelectedEvent(tab.id)),
                    onClose: () => bloc.add(TabCloseRequestedEvent(tab.id)),
                  );
                },
              ),
            ),
            if (tabs.isNotEmpty)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: Space.xxs),
                  child: _ImagesMenuWidget(
                    tooltip: words.imagesList,
                    images: [
                      for (final tab in tabs)
                        (tab.id, words.title(tab.title), tab.id == active),
                    ],
                    steps: [
                      for (final id in const ['next_image', 'previous_image'])
                        (
                          words.command(id),
                          PaintCatalog.shortcut(id),
                          () => bloc.add(CommandInvokedEvent(id)),
                        ),
                    ],
                    onSelect: (id) => bloc.add(TabSelectedEvent(id)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// One tab. Its width is the thumbnail's, so an image's shape, not its
/// name's length, sizes it; the name shortens under it and shows whole
/// in the tooltip.
class _TabWidget extends StatefulWidget {
  const _TabWidget({
    required this.name,
    required this.thumbnail,
    required this.isModified,
    required this.selected,
    required this.closeTooltip,
    required this.onSelect,
    required this.onClose,
  });

  final String name;
  final PixelBlock? thumbnail;
  final bool isModified;
  final bool selected;
  final String closeTooltip;
  final VoidCallback onSelect;
  final VoidCallback onClose;

  @override
  State<_TabWidget> createState() => _TabWidgetState();
}

class _TabWidgetState extends State<_TabWidget> {
  bool _hovered = false;

  /// The name's line under the thumbnail.
  static const double _label = 16;

  /// A very wide or tall image still gets a tab one can hit and read.
  static const double _minWidth = 44;
  static const double _maxWidth = 84;

  /// The name with «…» in the middle when it does not fit: its end (the
  /// number of an untitled image, the extension) tells names apart.
  static String _shorten(
    String name,
    TextStyle? style,
    double width,
    TextScaler scaler,
  ) {
    bool fits(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final fit = painter.width <= width;
      painter.dispose();
      return fit;
    }

    if (fits(name)) {
      return name;
    }
    final dot = name.lastIndexOf('.');
    final keep = dot > 0 && name.length - dot <= 5 ? name.length - dot : 2;
    final tail = name.substring(name.length - keep);
    for (var head = name.length - keep - 1; head > 0; head--) {
      final shortened = '${name.substring(0, head).trimRight()}…$tail';
      if (fits(shortened)) {
        return shortened;
      }
    }
    return '…$tail';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final label = text.labelSmall?.copyWith(
      color: widget.selected ? null : tokens.muted,
    );
    final block = widget.thumbnail;
    final aspect = block == null || block.height == 0
        ? 4 / 3
        : block.width / block.height;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.xxs / 2,
        vertical: Space.xxs,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbHeight =
              constraints.maxHeight - 2 * Space.xxs - _label - 2;
          final width = (thumbHeight * aspect).clamp(_minWidth, _maxWidth);
          return MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GlassTap(
              selected: widget.selected,
              onTap: widget.onSelect,
              padding: const EdgeInsets.all(Space.xxs),
              child: Tooltip(
                message: widget.name,
                waitDuration: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      SizedBox(
                        height: thumbHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: PixelBlockImageWidget(
                                block: block,
                                size: Size(width, thumbHeight),
                              ),
                            ),
                            if (widget.isModified)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: GlowDot(
                                  color: tokens.warning,
                                  size: 6,
                                  glow: false,
                                ),
                              ),
                            Positioned(
                              right: -Space.xxs / 2,
                              top: -Space.xxs / 2,
                              child: AnimatedOpacity(
                                duration: Motion.fast,
                                opacity: _hovered || widget.selected ? 1 : 0,
                                child: IgnorePointer(
                                  ignoring: !_hovered && !widget.selected,
                                  child: _CloseWidget(
                                    tooltip: widget.closeTooltip,
                                    onPressed: widget.onClose,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: _label,
                        child: Center(
                          child: Text(
                            _shorten(
                              widget.name,
                              label,
                              width,
                              MediaQuery.textScalerOf(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: label,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The close button on the thumbnail's corner, on a glass plate so it
/// reads over any picture.
class _CloseWidget extends StatelessWidget {
  const _CloseWidget({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  static const double _size = 16;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              context.tokens.glassStrong,
              Theme.of(context).colorScheme.surface,
            ),
            borderRadius: BorderRadius.circular(Radii.xxs),
            border: Border.all(color: context.tokens.hairline),
          ),
          child: const Icon(Icons.close_rounded, size: 11),
        ),
      ),
    ),
  );
}

/// The ▾ after the tabs: the open images, the chosen one checked, and
/// stepping to the next or previous one with its keys.
class _ImagesMenuWidget extends StatelessWidget {
  const _ImagesMenuWidget({
    required this.tooltip,
    required this.images,
    required this.steps,
    required this.onSelect,
  });

  final String tooltip;

  /// Id, name, whether it is the active one.
  final List<(int, String, bool)> images;

  /// Name, keys, action.
  final List<(String, String, VoidCallback)> steps;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => MenuAnchor(
    menuChildren: [
      for (final (id, name, active) in images)
        MenuItemButton(
          leadingIcon: SizedBox(
            width: ControlSize.icon,
            child: active ? const Icon(Icons.check_rounded, size: 14) : null,
          ),
          onPressed: () => onSelect(id),
          child: Text(name),
        ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: Space.xxs),
        child: Hairline(),
      ),
      for (final (name, keys, action) in steps)
        MenuItemButton(
          leadingIcon: const SizedBox(width: ControlSize.icon),
          trailingIcon: Padding(
            padding: const EdgeInsets.only(left: Space.lg),
            child: Text(
              keys,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.tokens.muted),
            ),
          ),
          onPressed: images.length > 1 ? action : null,
          child: Text(name),
        ),
    ],
    builder: (context, controller, _) => BarButtonWidget(
      tooltip: tooltip,
      size: ControlSize.field,
      onPressed: () =>
          controller.isOpen ? controller.close() : controller.open(),
      child: const Icon(Icons.expand_more_rounded),
    ),
  );
}
