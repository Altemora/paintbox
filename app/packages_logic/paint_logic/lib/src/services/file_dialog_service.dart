import 'package:file_selector/file_selector.dart';
import 'package:paint_bridge/paint_bridge.dart';

/// The system's open and save dialogs for the formats the core reads and
/// writes.
abstract class FileDialogService {
  /// File > Open: any number of images.
  Future<List<String>> openImages({String? directory});

  /// Layers > Import From File: one picture.
  Future<String?> openPicture({String? directory});

  /// File > Save As: the path with an extension the core writes.
  Future<String?> saveImage({required String suggestedName, String? directory});
}

class SystemFileDialogService implements FileDialogService {
  static List<XTypeGroup> _groups() {
    final extensions = fileExtensions();
    return [
      XTypeGroup(label: 'Images', extensions: extensions),
      for (final e in extensions)
        XTypeGroup(label: e.toUpperCase(), extensions: [e]),
    ];
  }

  @override
  Future<List<String>> openImages({String? directory}) async {
    final files = await openFiles(
      acceptedTypeGroups: _groups(),
      initialDirectory: directory,
    );
    return [for (final f in files) f.path];
  }

  @override
  Future<String?> openPicture({String? directory}) async {
    final file = await openFile(
      acceptedTypeGroups: _groups(),
      initialDirectory: directory,
    );
    return file?.path;
  }

  @override
  Future<String?> saveImage({
    required String suggestedName,
    String? directory,
  }) async {
    final groups = _groups().skip(1).toList();
    final location = await getSaveLocation(
      acceptedTypeGroups: groups,
      suggestedName: suggestedName,
      initialDirectory: directory,
    );
    if (location == null) {
      return null;
    }
    var path = location.path;
    // A name typed without an extension takes the chosen type's.
    if (fileKind(path: path) == null) {
      final chosen = location.activeFilter?.extensions?.first ?? 'ora';
      path = '$path.$chosen';
    }
    return path;
  }
}
