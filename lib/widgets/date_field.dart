import 'package:flutter/material.dart';

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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
      style: const TextStyle(fontStyle: FontStyle.italic),
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
