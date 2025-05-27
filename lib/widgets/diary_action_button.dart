import 'package:flutter/material.dart';

class DiaryActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color borderColor;

  const DiaryActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor = const Color(0xFFE8A951),
    this.iconColor = const Color(0xFF2E5355),
    this.textColor = const Color(0xFF2E5355),
    this.borderColor = const Color(0xFFA75119),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: iconColor),
      label: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 2),
        ),
      ),
    );
  }
}
