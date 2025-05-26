import 'package:flutter/material.dart';

class PolaroidPhoto extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final double angle;
  //final double height;

  const PolaroidPhoto({
    super.key,
    required this.imagePath,
    required this.backgroundColor,
    required this.angle,
    //required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Transform.rotate(
      angle: angle,
      child: Container(
        width: screenWidth * 0.35, // responsive width
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Image.asset(
          imagePath,
          //height: height,
          fit: BoxFit.cover, // better image handling
        ),
      ),
    );
  }
}
