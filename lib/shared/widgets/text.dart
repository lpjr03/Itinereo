import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A simple text widget using the PlaypenSans font with bold styling.
/// ```
class TextWidget extends StatelessWidget {
  /// The text string to display.
  final String title;

  /// Font size of the text.
  final double txtSize;

  /// Color of the text.
  final Color txtColor;

  /// Creates a [TextWidget] with the given [title], [txtSize], and [txtColor].
  const TextWidget({
    super.key,
    required this.title,
    required this.txtSize,
    required this.txtColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.playpenSans(
        fontSize: txtSize,
        fontWeight: FontWeight.bold,
        color: txtColor,
      ),
    );
  }
}
