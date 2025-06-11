import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable button widget for the Itinereo app, with built-in loading state.
///
/// - Displays a text label or a loading spinner
/// - Executes an action when tapped via [onPress]
/// - Shows a [CircularProgressIndicator] when [isLoading] is true
class LoadingButton extends StatelessWidget {
  /// The text label displayed inside the button when not loading.
  final String btnText;

  /// Callback triggered when the button is tapped.
  final VoidCallback onPress;

  /// Whether the button should display a loading spinner instead of text.
  ///
  /// When true, disables the label and shows a [CircularProgressIndicator].
  final bool isLoading;

  /// Creates a [LoadingButton] with a label and optional loading indicator.
  const LoadingButton({
    super.key,
    this.isLoading = false,
    required this.onPress,
    required this.btnText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF20535B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Text(
                btnText,
                style: GoogleFonts.libreBaskerville(
                  fontSize: 16,
                  color: Color(0xFFF3E2C7),
                ),
              ),
    );
  }
}
