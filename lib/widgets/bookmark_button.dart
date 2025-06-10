import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookMark extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color textAndIconColor;
  final Color backgroundColor;

  const BookMark({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    required this.textAndIconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          children: [
            Icon(icon, size: 37, color: textAndIconColor),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children:
                    label!.split('').map((lettera) {
                      return Text(
                        lettera,
                        style: GoogleFonts.playpenSans(
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: textAndIconColor,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
