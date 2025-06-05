import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateField extends StatefulWidget {
  final TextEditingController dateController;
  const DateField({super.key, required this.dateController});

  @override
  State<DateField> createState() =>
      _DateFieldState(dateController: dateController);
}

class _DateFieldState extends State<DateField> {
  final TextEditingController dateController;

  _DateFieldState({required this.dateController});
  @override
  void initState() {
    super.initState();
    dateController.text = _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF385A55), 
              onPrimary: Colors.white, 
              onSurface: Color(0xFF385A55), 
              surface: Color(0xFFF6ECD4), 
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF385A55),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: dateController,
      readOnly: true,
      onTap: _pickDate,
      style: GoogleFonts.playpenSans(
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF373737),
        ),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF6ECD4),
        hintText: 'Select date',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD8CCB1), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD8CCB1), width: 2),
        ),
      ),
    );
  }
}
