import 'package:paint_bridge/src/rust/api/types.dart' as rust;

/// The core's rectangle of pixels under a name that does not clash with
/// `dart:ui`'s `Rect`.
typedef PaintRect = rust.Rect;

/// The Curves adjustment's points under a name that does not clash with
/// Flutter's animation `Curves`.
typedef PaintCurves = rust.Curves;

/// Text's alignment under a name that does not clash with Flutter's
/// `TextAlign`.
typedef PaintTextAlign = rust.TextAlign;
