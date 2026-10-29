import 'package:app_ui/src/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// One-pixel separator in the hairline colour, instead of `Divider`.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.vertical = false, this.indent = 0});

  final bool vertical;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.hairline;
    return vertical
        ? Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: indent),
            color: color,
          )
        : Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: indent),
            color: color,
          );
  }
}
