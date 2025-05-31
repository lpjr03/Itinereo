import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PolaroidPhoto extends StatelessWidget {
  final String? imagePath; 
  final Widget? content; 
  final Color backgroundColor;
  final double angle;
  final bool isAsset;
  final String? caption;
  final double? width;
  final Widget? trailingAction;

  const PolaroidPhoto({
    super.key,
    this.imagePath,
    this.content,
    required this.backgroundColor,
    this.angle = 0,
    this.isAsset = false,
    this.caption,
    this.width,
    this.trailingAction,
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

    final borderWidth = caption == null ? 10.0 : 15.0;

    return Transform.rotate(
      angle: angle,
      child: Container(
        width: w,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          border:
              caption == null
                  ? Border.all(color: backgroundColor, width: borderWidth)
                  : Border(
                    top: BorderSide(color: backgroundColor, width: borderWidth),
                    left: BorderSide(
                      color: backgroundColor,
                      width: borderWidth,
                    ),
                    right: BorderSide(
                      color: backgroundColor,
                      width: borderWidth,
                    ),
                    bottom: BorderSide(
                      color: backgroundColor,
                      width: borderWidth,
                    ),
                  ),
        ),
        child:
            caption == null
                ? AspectRatio(aspectRatio: 1, child: mainContent)
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(aspectRatio: 4 / 3, child: mainContent),
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
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
                          if (trailingAction != null) trailingAction!,
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
