import 'package:flutter/material.dart';
import 'package:itinereo/shared/widgets/safe_local_image.dart';

/// A styled photo container inspired by polaroid photography,
/// supporting local, network, and asset images.
///
/// This widget:
/// - Displays the image inside a square frame
/// - Optionally rotates the image with [angle]
/// - Supports shadows, borders, and dynamic width
/// - Automatically chooses how to render the image based on its path
class PolaroidPhoto extends StatelessWidget {
  /// Path to the image. Can be a local file path, asset name, or network URL.
  final String imagePath;

  /// Background color of the polaroid frame and the border.
  final Color backgroundColor;

  /// Rotation angle in radians (e.g., 0.1 for slight tilt).
  final double angle;

  /// Whether the image is an asset. Set to true for bundled assets.
  final bool isAsset;

  /// Optional width of the widget. Defaults to 35% of screen width.
  final double? width;

  /// Whether to show a soft drop shadow below the photo.
  final bool showShadow;

  /// Width of the border around the image.
  final double borderWidth;

  /// Creates a [PolaroidPhoto] widget with customizable presentation.
  const PolaroidPhoto({
    super.key,
    required this.imagePath,
    required this.backgroundColor,
    this.angle = 0,
    this.isAsset = false,
    this.width,
    this.showShadow = true,
    this.borderWidth = 10,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final w = width ?? screenWidth * 0.35;

    Widget mainContent;

    ///Determine image source
    if (isAsset) {
      mainContent = Image.asset(imagePath, fit: BoxFit.cover);
    } else if (imagePath.startsWith('http')) {
      mainContent = Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } else {
      mainContent = SafeLocalImage(path: imagePath, fit: BoxFit.cover);
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
          border: Border.all(color: backgroundColor, width: borderWidth),
        ),
        child: AspectRatio(aspectRatio: 1, child: mainContent),
      ),
    );
  }
}
