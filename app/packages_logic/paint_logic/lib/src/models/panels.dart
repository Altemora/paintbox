import 'dart:ui';

import 'package:equatable/equatable.dart';

/// Which floating windows are shown (F5 - F8), and whether Colors shows
/// More (the sliders and the whole palette) or Less (the wheel alone),
/// and where each window was dragged from its corner.
final class Panels extends Equatable {
  const Panels({
    this.tools = true,
    this.history = true,
    this.layers = true,
    this.colors = true,
    this.colorsMore = true,
    this.places = const {},
  });

  final bool tools;
  final bool history;
  final bool layers;
  final bool colors;
  final bool colorsMore;

  /// A window's offset from its corner by its id (`tools`, `history`,
  /// `layers`, `colors`); none is the corner itself.
  final Map<String, Offset> places;

  Offset placeOf(String id) => places[id] ?? Offset.zero;

  Panels copyWith({
    bool? tools,
    bool? history,
    bool? layers,
    bool? colors,
    bool? colorsMore,
    Map<String, Offset>? places,
  }) => Panels(
    tools: tools ?? this.tools,
    history: history ?? this.history,
    layers: layers ?? this.layers,
    colors: colors ?? this.colors,
    colorsMore: colorsMore ?? this.colorsMore,
    places: places ?? this.places,
  );

  Panels withPlace(String id, Offset offset) =>
      copyWith(places: {...places, id: offset});

  Panels withTools(bool value) => copyWith(tools: value);

  Panels withHistory(bool value) => copyWith(history: value);

  Panels withLayers(bool value) => copyWith(layers: value);

  Panels withColors(bool value) => copyWith(colors: value);

  @override
  List<Object?> get props => [
    tools,
    history,
    layers,
    colors,
    colorsMore,
    places,
  ];
}
