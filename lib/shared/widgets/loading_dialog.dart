import 'package:flutter/material.dart';

/// A custom modal dialog that displays a loading spinner with a message.
///
/// Used to indicate that an operation is in progress.
/// Prevents dismissal unless explicitly closed programmatically.
class LoadingDialog extends StatelessWidget {
  /// Message displayed next to the loading indicator.
  final String message;

  /// Creates a [LoadingDialog] with a centered message and a spinner.
  const LoadingDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF6ECD4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF2E5355), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showLoadingDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return LoadingDialog(message: message);
    },
  );
}
