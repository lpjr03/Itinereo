import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A customizable and reusable [TextFormField] widget with enhanced styling,
/// built-in multiline support, optional validation, and rich text formatting.
///
/// This widget is designed to offer flexibility and consistent styling across
/// forms or inputs, with sensible defaults and optional overrides.
///
class CustomTextFormField extends StatelessWidget {
  /// Controls the text being edited.
  final TextEditingController controller;

  /// Hint text displayed when the input is empty.
  final String hintText;

  /// Custom style for the input text. If not provided, uses default font.
  final TextStyle? textStyle;

  /// Custom style for the hint text. If not provided, uses default font.
  final TextStyle? hintStyle;

  /// Border for all states (enabled, focused, etc.). If not provided, uses a default rounded border.
  final InputBorder? border;

  /// Enables multi-line input when set to `true`.
  final bool multiline;

  /// Disables editing if set to `true`.
  final bool readOnly;

  /// Defines the alignment of the entered text (e.g., start, center).
  final TextAlign textAlign;

  /// Validation logic to be applied to the field value.
  final FormFieldValidator<String>? validator;

  /// Background color of the input field. Defaults to a soft cream tone.
  final Color? fillColor;

  /// Minimum number of lines to occupy when multiline is true.
  final int? minLines;

  /// Maximum number of lines allowed when multiline is true.
  final int? maxLines;

  /// Input formatters to apply (e.g., filtering digits, uppercasing).
  final List<TextInputFormatter>? inputFormatters;

  /// Internal padding inside the input field. Defaults to vertical spacing.
  final EdgeInsetsGeometry? contentPadding;

  /// Callback triggered when the text is changed.
  final ValueChanged<String>? onChanged;

  /// Controls capitalization behavior (e.g., sentences, words, characters).
  final TextCapitalization capitalization;

  /// Creates a [CustomTextFormField] with extended customization and formatting options.
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.textStyle,
    this.hintStyle,
    this.border,
    this.multiline = false,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.validator,
    this.fillColor,
    this.minLines,
    this.maxLines,
    this.inputFormatters,
    this.contentPadding,
    this.onChanged,
    this.capitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = GoogleFonts.playpenSans(
      textStyle: const TextStyle(fontSize: 16, color: Color(0xFF2E5355)),
    );

    final defaultHintStyle = GoogleFonts.playpenSans(
      textStyle: const TextStyle(fontSize: 16, color: Color(0xFF2E5355)),
    );

    return TextFormField(
      controller: controller,
      textAlign: textAlign,
      minLines: multiline ? (minLines ?? 1) : 1,
      maxLines: multiline ? (maxLines ?? 10) : 1,
      keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
      readOnly: readOnly,
      onChanged: onChanged,
      style: textStyle ?? defaultTextStyle,
      validator: validator,
      inputFormatters: inputFormatters,
      textCapitalization: capitalization,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ?? defaultHintStyle,
        filled: true,
        fillColor: fillColor ?? const Color(0xFFF9EDD2),
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border:
            border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD8CCB1), width: 2),
            ),
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
