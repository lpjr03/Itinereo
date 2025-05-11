import 'package:flutter/material.dart';

/// A custom styled button widget used in the Itinereo app.
///
/// This button:
/// - Has a fixed background color (`#20535B`)
/// - Uses rounded corners with a radius of 10
/// - Displays a text label passed via [btnText]
/// - Executes the [onPress] callback when tapped
///
class ButtonWidget extends StatelessWidget {
  /// The text displayed inside the button.
  final String btnText;

  /// The callback function executed when the button is pressed.
  final VoidCallback onPress;

  /// Creates a [ButtonWidget] with a text label and an action.
  const ButtonWidget({
    super.key,
    required this.btnText,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF20535B), // deep blue
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        btnText,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFFF3E2C7), // light beige
        ),
      ),
    );
  }
}
