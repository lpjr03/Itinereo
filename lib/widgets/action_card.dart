import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double iconSize;
  final String? tooltip;
  final Color iconColor;
  final Color backgroundColor;
  final double width;

  const ActionCard({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_a_photo,
    this.iconSize = 90,
    this.tooltip,
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
          tooltip: tooltip,
        ),
      ),
    );
  }
}
