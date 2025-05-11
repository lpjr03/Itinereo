import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItinereoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color textColor;
  final Color pillColor;
  final Color topBarColor;

  const ItinereoAppBar({
    super.key,
    required this.title,
    required this.textColor,
    required this.pillColor,
    required this.topBarColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Container(height: 55, color: topBarColor),
              Container(height: 35, color: const Color(0xFFF6ECD4)),
            ],
          ),
          Positioned(
            top: 35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 3),
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                title,
                style: GoogleFonts.libreBaskerville(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
