import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFBBBEBF),
      textTheme: GoogleFonts.playpenSansTextTheme(),
      fontFamily:
          GoogleFonts.playpenSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF385A55)),
      useMaterial3: true,
    );
  }
}
