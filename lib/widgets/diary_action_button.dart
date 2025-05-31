import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color borderColor;

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
            //height: 28 / 16, 
            //letterSpacing: -0.04 * 16, 
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
