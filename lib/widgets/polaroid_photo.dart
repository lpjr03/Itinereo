import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PolaroidPhoto extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final double angle;
  final bool isAsset;
  final String? caption;
  final double? width;

  const PolaroidPhoto({
    super.key,
    required this.imagePath,
    required this.backgroundColor,
    this.angle = 0,
    this.isAsset = false,
    this.caption,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    ImageProvider imageProvider;
    if (isAsset) {
      imageProvider = AssetImage(imagePath);
    } else if (imagePath.startsWith('http')) {
      imageProvider = NetworkImage(imagePath);
    } else {
      imageProvider = FileImage(File(imagePath));
    }

    if (caption == null) {
      return Transform.rotate(
        angle: angle,
        child: Container(
          width: width ?? screenWidth * 0.35,
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            border: Border.all(color: backgroundColor, width: 10),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
      );
    }

    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width ?? screenWidth * 0.35,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          border: Border(
            top: BorderSide(color: backgroundColor, width: 20),
            left: BorderSide(color: backgroundColor, width: 20),
            right: BorderSide(color: backgroundColor, width: 20),
            bottom: BorderSide(color: backgroundColor, width: 20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image(image: imageProvider, fit: BoxFit.cover),
            ),
            Container(
              padding: const EdgeInsets.only(top:20),
              alignment: Alignment.center,
              child: Text(
                caption!,
                style: GoogleFonts.courierPrime(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
