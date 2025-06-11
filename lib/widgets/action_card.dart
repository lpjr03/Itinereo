import 'package:flutter/material.dart';

/// A customizable card-like button with a centered icon,
/// used for triggering actions like adding a photo.
class ActionCard extends StatelessWidget {
  /// Callback executed when the icon button is pressed.
  final VoidCallback onPressed;

  /// The icon displayed in the center of the card.
  final IconData icon;

  /// The size of the icon.
  final double iconSize;

  /// Color of the icon.
  final Color iconColor;

  /// Background color of the card.
  final Color backgroundColor;

  /// Width of the card.
  final double width;

  /// Creates an [ActionCard] with customizable appearance and behavior.
  const ActionCard({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_a_photo,
    this.iconSize = 90,
    this.iconColor = const Color(0xFF2E5355),
    this.backgroundColor = const Color(0xFFFFF2D8),
    this.width = 325,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: const Color(0xFFFFF9EA), width: 20),
      ),
      child: Center(
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: iconSize, color: iconColor),
          splashRadius: 32,
        ),
      ),
    );
  }
}
