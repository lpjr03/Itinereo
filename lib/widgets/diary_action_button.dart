import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A customizable button used for diary-related actions.
///
/// Displays an icon and a label side by side, with full control
/// over colors, border styling, and padding. Useful for
/// a consistent look across the UI.
/// ```
class DiaryActionButton extends StatelessWidget {
  /// Callback executed when the button is tapped.
  final VoidCallback onPressed;

  /// Icon displayed at the start of the button.
  final IconData icon;

  /// Text label displayed next to the icon.
  final String label;

  /// Background color of the button.
  final Color backgroundColor;

  /// Color of the icon.
  final Color iconColor;

  /// Color of the text label.
  final Color textColor;

  /// Color of the button border.
  final Color borderColor;

  /// Creates a [DiaryActionButton] with the specified properties.
  const DiaryActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 25, color: iconColor),
      label: Text(
        label,
        style: GoogleFonts.playpenSans(
          textStyle: TextStyle(
            fontSize: 17,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 2.7),
        ),
      ),
    );
  }
}
