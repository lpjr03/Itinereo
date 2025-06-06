import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom styled button widget used in the Itinereo app.
///
/// This button:
/// - Has a fixed background color (`#20535B`)
/// - Uses rounded corners with a radius of 10
/// - Displays a text label passed via [btnText]
/// - Executes the [onPress] callback when tapped
///
class LoadingButton extends StatelessWidget {
  /// The text displayed inside the button.
  final String btnText;

  /// The callback function executed when the button is pressed.
  final VoidCallback onPress;

  /// Loading fleck that checks whether show a [CircularProgressIndicator]
  final bool isLoading;

  /// Creates a [LoadingButton] with a text label and an action.
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: isLoading
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
        style:  GoogleFonts.libreBaskerville(
          fontSize: 16,
          color: Color(0xFFF3E2C7),
        ),
      ),

    );
  }
}
