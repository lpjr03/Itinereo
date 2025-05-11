import 'package:flutter/material.dart';

class InputTxtField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;

  const InputTxtField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
    this.obscureText = false,
  });

  @override
  State<InputTxtField> createState() => _InputTxtFieldState();
}

class _InputTxtFieldState extends State<InputTxtField> {
  String? errorText;

  void _validate(String value) {
    if (widget.validator != null) {
      final result = widget.validator!(value);
      setState(() {
        errorText = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          onChanged: _validate,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: errorText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}
