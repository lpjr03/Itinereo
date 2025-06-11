import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the global visual theme for the Itinerèo app.
///
/// This class provides a consistent appearance across the application,
/// using a light color scheme with custom typography via Google Fonts.
class AppTheme {
  /// The default light theme for the app.
  ///
  /// Includes:
  /// - A light brightness setting.
  /// - Custom scaffold background color (`Color(0xFFBBBEBF)`).
  /// - Typography from Google Fonts' Playpen Sans.
  /// - A color scheme generated from a seed color (`Color(0xFF385A55)`).
  /// - Material 3 design system enabled.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFBBBEBF),
      textTheme: GoogleFonts.playpenSansTextTheme(),
      fontFamily: GoogleFonts.playpenSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF385A55)),
      useMaterial3: true,
    );
  }
}
