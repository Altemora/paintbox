/// The command line: images to open, or `--screenshot=<png>` with an
/// optional `--scene=<name>` and the pictures' look: `--theme=dark|light`,
/// `--accent=<blue|green|amber|purple|red|gray>`, `--language=<code>`.
final class LaunchOptions {
  const LaunchOptions({
    this.paths = const [],
    this.screenshot,
    this.scene,
    this.theme,
    this.accent,
    this.language,
  });

  factory LaunchOptions.parse(List<String> args) {
    final values = <String, String>{};
    final paths = <String>[];
    for (final arg in args) {
      if (arg.startsWith('--') && arg.contains('=')) {
        final split = arg.indexOf('=');
        values[arg.substring(2, split)] = arg.substring(split + 1);
      } else if (!arg.startsWith('--')) {
        paths.add(arg);
      }
    }
    return LaunchOptions(
      paths: paths,
      screenshot: values['screenshot'],
      scene: values['scene'],
      theme: values['theme'],
      accent: values['accent'],
      language: values['language'],
    );
  }

  final List<String> paths;
  final String? screenshot;
  final String? scene;
  final String? theme;
  final String? accent;
  final String? language;

  /// Screenshots neither read nor write the user's settings or clipboard.
  bool get isScreenshot => screenshot != null;
}
