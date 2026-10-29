/// The command line: images to open, or `--screenshot=<png>` with an
/// optional `--scene=<name>`.
final class LaunchOptions {
  const LaunchOptions({this.paths = const [], this.screenshot, this.scene});

  factory LaunchOptions.parse(List<String> args) {
    String? screenshot;
    String? scene;
    final paths = <String>[];
    for (final arg in args) {
      if (arg.startsWith('--screenshot=')) {
        screenshot = arg.substring('--screenshot='.length);
      } else if (arg.startsWith('--scene=')) {
        scene = arg.substring('--scene='.length);
      } else if (!arg.startsWith('--')) {
        paths.add(arg);
      }
    }
    return LaunchOptions(paths: paths, screenshot: screenshot, scene: scene);
  }

  final List<String> paths;
  final String? screenshot;
  final String? scene;

  /// Screenshots neither read nor write the user's settings or clipboard.
  bool get isScreenshot => screenshot != null;
}
