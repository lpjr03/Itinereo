import 'package:flutter/material.dart';
import 'package:itinereo/widgets/text_widget.dart';

/// A themed AlertDialog used in the Itinereo app for error or confirmation messages.
class ErrorDialog extends StatelessWidget {
  /// The message to display in the dialog.
  final String message;

  /// Optional title of the dialog.
  final String title;

  /// Text for the OK button (default: "OK").
  final String okButtonText;

  /// Whether to show a cancel button (default: false).
  final bool showCancelButton;

  /// Text for the cancel button (default: "Annulla").
  final String cancelButtonText;

  /// Optional callback when pressing OK.
  final VoidCallback? onOk;

  /// Optional callback when pressing Cancel.
  final VoidCallback? onCancel;

  const ErrorDialog({
    super.key,
    required this.message,
    this.title = 'Error!',
    this.okButtonText = 'OK',
    this.showCancelButton = false,
    this.cancelButtonText = 'Annulla',
    this.onOk,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF3E2C7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          onPressed: () {
            Navigator.pop(context);
            onOk?.call();
          },
          child: TextWidget(
            title: okButtonText,
            txtSize: 16.0,
            txtColor: const Color(0xFF20535B),
          ),
        ),
        if (showCancelButton)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: TextWidget(
              title: cancelButtonText,
              txtSize: 16.0,
              txtColor: const Color(0xFF20535B),
            ),
          ),
      ],
    );
  }
}
