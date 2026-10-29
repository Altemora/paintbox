import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/models/open_image.dart';
import 'package:paint_logic/src/paint_call.dart';

/// The open images, in the order of the tab strip. It makes, opens,
/// saves and closes them; which one is active is the screen's business.
class ImagesRepository {
  final List<OpenImage> _images = [];
  int _nextId = 1;
  int _untitled = 0;

  List<OpenImage> get images => List.unmodifiable(_images);

  OpenImage? byId(int id) {
    for (final image in _images) {
      if (image.id == id) {
        return image;
      }
    }
    return null;
  }

  /// File > New: an image filled with [background].
  OpenImage createBlank({
    required int width,
    required int height,
    required Rgba8 background,
    required UserColors colors,
  }) => _add(
    PaintCall.run(
      () => PaintImage.blank(
        width: width,
        height: height,
        background: background,
        colors: colors,
      ),
    ),
  );

  /// Edit > Paste into New Image.
  OpenImage fromClip(ClipImage clip, UserColors colors) => _add(
    PaintCall.run(() => PaintImage.fromClip(clip: clip, colors: colors)),
  );

  /// Reads a file on the bridge's worker. Without [keepPath] the image
  /// is untitled: a picture a browser dropped from its temporary folder
  /// is saved where the user chooses, not back there.
  Future<OpenImage> open(
    String path,
    UserColors colors, {
    bool keepPath = true,
  }) async {
    final image = await PaintCall.runAsync(() => openImage(path: path));
    PaintCall.run(
      () => image.setColors(colors: colors, settings: defaultToolSettings()),
    );
    final opened = keepPath
        ? OpenImage(id: _nextId++, image: image, path: path)
        : OpenImage(id: _nextId++, image: image, untitledNumber: ++_untitled);
    _images.add(opened);
    return opened;
  }

  /// The image whose file is [path], if it is open.
  OpenImage? byPath(String path) {
    final key = _key(path);
    for (final image in _images) {
      if (image.path != null && _key(image.path!) == key) {
        return image;
      }
    }
    return null;
  }

  /// Writes [id] to [path] (the format by its extension) from a snapshot
  /// taken now, so painting may go on while it is written; the image
  /// counts as saved in the state the snapshot had.
  Future<OpenImage> save(
    int id,
    String path, {
    required int jpegQuality,
  }) async {
    final open = byId(id);
    if (open == null) {
      throw StateError('no image $id');
    }
    final image = open.image;
    final state = PaintCall.run(image.stateId);
    final snapshot = PaintCall.run(image.snapshot);
    try {
      await PaintCall.runAsync(
        () => writeSnapshot(
          snapshot: snapshot,
          path: path,
          jpegQuality: jpegQuality,
        ),
      );
    } finally {
      snapshot.dispose();
    }
    PaintCall.run(() => image.markSavedAt(stateId: state));
    final saved = open.withPath(path);
    _replace(saved);
    return saved;
  }

  /// A tab dragged to [index] of the strip.
  void move(int id, int index) {
    final from = _images.indexWhere((i) => i.id == id);
    if (from < 0) {
      return;
    }
    final image = _images.removeAt(from);
    _images.insert(index.clamp(0, _images.length), image);
  }

  void close(int id) {
    final index = _images.indexWhere((i) => i.id == id);
    if (index < 0) {
      return;
    }
    _images.removeAt(index).image.dispose();
  }

  OpenImage _add(PaintImage image) {
    final open = OpenImage(
      id: _nextId++,
      image: image,
      untitledNumber: ++_untitled,
    );
    _images.add(open);
    return open;
  }

  void _replace(OpenImage image) {
    final index = _images.indexWhere((i) => i.id == image.id);
    if (index >= 0) {
      _images[index] = image;
    }
  }

  static String _key(String path) => path.replaceAll('\\', '/').toLowerCase();
}
