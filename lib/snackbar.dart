import 'package:flutter/material.dart';

/// Utility class to show a custom Itinereo-style SnackBar.
class ItinereoSnackBar {
  /// Displays a styled SnackBar with a given [message].
  ///
  /// The SnackBar uses the Itinereo color palette and appears floating
  /// with rounded corners.
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF20535B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFFF3E2C7),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
