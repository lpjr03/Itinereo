import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildExploreTile({
  required IconData icon,
  required String label,
  required Color iconBackground,
  required Color labelBackground,
  double width = 170,
}) {
  return Stack(
    alignment: Alignment.centerLeft,
    children: [
      Container(
        width: width,
        margin: const EdgeInsets.only(left: 25),
        padding: const EdgeInsets.fromLTRB(50, 16, 20, 16),
        decoration: BoxDecoration(
          color: labelBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.deliciousHandrawn(
                  fontSize: 24,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
      CircleAvatar(
        radius: 32,
        backgroundColor: iconBackground,
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    ],
  );
}
