import 'package:flutter/material.dart';

class InputTxtField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;

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
      keyboardType:keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
