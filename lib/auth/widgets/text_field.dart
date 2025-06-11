import 'package:flutter/material.dart';

/// A configurable text input field.
///
/// This widget wraps [TextFormField] and provides:
/// - Validation support
/// - Obscure text (for passwords)
/// - Custom capitalization and keyboard type
/// - Simple outlined style with padding
///
/// Useful for login forms, registration, or general user input.
class InputTxtField extends StatelessWidget {
  /// Text displayed when the field is empty.
  final String hintText;

  /// Controller used to read and write the input field's text.
  final TextEditingController controller;

  /// Optional validation function returning an error string if invalid.
  final String? Function(String?)? validator;

  /// Whether the text should be hidden (e.g. for passwords).
  final bool obscureText;

  /// Whether to enable the device's autocorrect functionality.
  final bool autocorrect;

  /// How the text input should be capitalized.
  final TextCapitalization textCapitalization;

  /// The type of keyboard to use for text input.
  final TextInputType keyboardType;

  /// Creates an [InputTxtField] with optional behaviors like validation,
  /// password protection, autocorrection, and keyboard customization.
  const InputTxtField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.autocorrect = false,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
