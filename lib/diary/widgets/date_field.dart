import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom date selection field based on [TextFormField] with integrated date picker.
///
/// The user can tap the field to open a themed calendar dialog and select a date.
/// The selected date is then formatted as `dd/MM/yyyy` and displayed in the field.
///
/// The date can only be chosen from the past (between 1900 and today).
class DateField extends StatefulWidget {
  /// Controller used to get or set the selected date.
  final TextEditingController dateController;

  /// Creates a [DateField] widget.
  ///
  /// Requires a [TextEditingController] to read or update the field externally.
  const DateField({super.key, required this.dateController});

  @override
  State<DateField> createState() =>
      _DateFieldState(dateController: dateController);

      
  static DateTime parseDate(String input) {
    final parts = input.split('/');
    if (parts.length != 3) return DateTime.now(); // fallback

    final int day = int.parse(parts[0]);
    final int month = int.parse(parts[1]);
    final int year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }
}

class _DateFieldState extends State<DateField> {
  final TextEditingController dateController;

  _DateFieldState({required this.dateController});
  @override
  void initState() {
    super.initState();

    /// Initializes the date field with today's date as default.
    dateController.text = _formatDate(DateTime.now());
  }

  /// Formats a [DateTime] as a string in `dd/MM/yyyy` format.
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Opens a themed date picker and updates the text field with the selected date.
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
              style: TextButton.styleFrom(foregroundColor: Color(0xFF385A55)),
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

  

