import 'package:flutter/material.dart';

/// A utility class for displaying custom-styled SnackBars
/// consistent with the Itinereo design.
class ItinereoSnackBar {
  /// Displays a floating [SnackBar] with the given [message] and Itinereo styling.
  /// [context] is the build context used to access the [ScaffoldMessenger].
  /// [message] is the text content to be displayed in the SnackBar.
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF20535B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
