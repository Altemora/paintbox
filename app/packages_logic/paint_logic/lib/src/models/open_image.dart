import 'package:equatable/equatable.dart';
import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/session/image_session.dart';

/// One image of the tab strip: the core's image with where it lives on
/// disk. An image never saved has no [path] and is called by its
/// [untitledNumber].
final class OpenImage extends Equatable {
  const OpenImage({
    required this.id,
    required this.image,
    this.path,
    this.untitledNumber,
  });

  final int id;
  final PaintImage image;
  final String? path;
  final int? untitledNumber;

  /// How the screen reads the image.
  ImageSession get session => ImageSession(image);

  OpenImage withPath(String path) =>
      OpenImage(id: id, image: image, path: path);

  @override
  List<Object?> get props => [id, path, untitledNumber];
}
