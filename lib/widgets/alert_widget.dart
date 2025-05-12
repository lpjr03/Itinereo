import 'package:flutter/material.dart';
import 'package:itinereo/widgets/text_widget.dart';

/// A themed AlertDialog used in the Itinereo app to show error messages.
///
class ErrorDialog extends StatelessWidget {
  /// The message to display in the dialog.
  final String message;

  /// Optional title of the dialog.
  final String title;

  /// Creates an [ErrorDialog] styled for Itinereo.
  const ErrorDialog({
    super.key,
    required this.message,
    this.title = 'Error!',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF3E2C7),
      title: TextWidget(
        title: title,
        txtSize: 24.0,
        txtColor: const Color(0xFF20535B),
      ),
      content: TextWidget(
        title: message,
        txtSize: 18.0,
        txtColor: const Color(0xFF20535B),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: TextWidget(
            title: "OK",
            txtSize: 16.0,
            txtColor: const Color(0xFF20535B),
          ),
        ),
      ],
    );
  }
}