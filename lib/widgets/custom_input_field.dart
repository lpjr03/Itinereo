import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final InputBorder? border;
  final bool multiline;
  final bool readOnly;
  final TextAlign textAlign;
  final FormFieldValidator<String>? validator;
  final Color? fillColor;

  const CustomTextFormField({
    Key? key,
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
  }) : super(key: key);

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
      maxLines: multiline ? 6 : 1,
      readOnly: readOnly,
      style: textStyle ?? defaultTextStyle,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ?? defaultHintStyle,
        filled: true,
        fillColor: fillColor ?? const Color(0xFFF9EDD2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
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
