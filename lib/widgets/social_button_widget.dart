import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable button widget for third-party/social logins.
///
/// Displays a button with:
/// - A background color ([bgColor])
/// - An image (e.g. social media logo)
/// - A label ([buttonName])
/// - A tap handler ([onPress])
///
/// Useful for login or registration flows where social authentication is supported.
class SocialButtonWidget extends StatelessWidget {
  /// Background color of the button.
  final Color bgColor;

  /// Path to the logo/image asset displayed to the left of the text.
  final String imagePath;

  /// Label displayed as button text.
  final String buttonName;

  /// Callback triggered when the button is pressed.
  final VoidCallback onPress;

  /// Creates a [SocialButtonWidget] with an image and label.
  const SocialButtonWidget({
    super.key,
    required this.bgColor,
    required this.imagePath,
    required this.buttonName,
    required this.onPress,
  });
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPress,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(bgColor),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, width: 20),
          const SizedBox(width: 8),
          Text(
            buttonName,
            style: GoogleFonts.libreBaskerville(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
