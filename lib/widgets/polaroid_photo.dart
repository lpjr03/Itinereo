import 'dart:io';
import 'package:flutter/material.dart';

class PolaroidPhoto extends StatelessWidget {
  final String? imagePath;
  final Widget? content;
  final Color backgroundColor;
  final double angle;
  final bool isAsset;
  final double? width;
  final Widget? trailingAction;
  final bool showShadow;

  const PolaroidPhoto({
    super.key,
    this.imagePath,
    this.content,
    required this.backgroundColor,
    this.angle = 0,
    this.isAsset = false,
    this.width,
    this.trailingAction,
    this.showShadow = true,
  }) : assert(
         imagePath != null || content != null,
         'You must provide an image or content',
       );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final w = width ?? screenWidth * 0.35;

    Widget mainContent;

    if (content != null) {
      mainContent = content!;
    } else {
      ImageProvider imageProvider;
      if (isAsset) {
        imageProvider = AssetImage(imagePath!);
      } else if (imagePath!.startsWith('http')) {
        imageProvider = NetworkImage(imagePath!);
      } else {
        imageProvider = FileImage(File(imagePath!));
      }

      mainContent = Image(image: imageProvider, fit: BoxFit.cover);
    }

    return Transform.rotate(
      angle: angle,
      child: Container(
        width: w,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow:
              showShadow
                  ? const [BoxShadow(color: Colors.black26, blurRadius: 8)]
                  : [],
          border: Border.all(color: backgroundColor, width: 10),
        ),
        child: AspectRatio(aspectRatio: 1, child: mainContent),
      ),
    );
  }
}
