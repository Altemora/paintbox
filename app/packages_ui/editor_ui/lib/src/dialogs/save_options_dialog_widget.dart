import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Before saving to a flat format: flattening the layers is agreed here,
/// and a JPEG gets its quality. Answers the quality, or null to cancel.
class SaveOptionsDialogWidget extends StatefulWidget {
  const SaveOptionsDialogWidget({
    required this.path,
    required this.flatten,
    required this.quality,
    super.key,
  });

  final String path;
  final bool flatten;

  /// Null when the format has no quality.
  final int? quality;

  @override
  State<SaveOptionsDialogWidget> createState() =>
      _SaveOptionsDialogWidgetState();
}

class _SaveOptionsDialogWidgetState extends State<SaveOptionsDialogWidget> {
  late double _quality = (widget.quality ?? 95).toDouble();

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final format = p.extension(widget.path).replaceFirst('.', '').toUpperCase();
    return AppDialogs.card(
      context,
      title: widget.flatten ? words.flattenTitle : words.jpegQualityTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.flatten) Text(words.flattenMessage(format)),
          if (widget.quality != null)
            Row(
              children: [
                Text(words.quality),
                Expanded(
                  child: Slider(
                    value: _quality,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    onChanged: (v) => setState(() => _quality = v),
                  ),
                ),
                SizedBox(width: 32, child: Text('${_quality.round()}')),
              ],
            ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(words.cancel),
        ),
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(_quality.round()),
          child: Text(widget.flatten ? words.flatten : words.save),
        ),
      ],
    );
  }
}
