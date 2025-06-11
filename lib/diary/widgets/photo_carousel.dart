import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:itinereo/diary/widgets/polaroid_photo.dart';

/// A custom horizontal photo carousel used in the Itinereo app.
///
/// Displays a list of photo URLs as [PolaroidPhoto] widgets inside a [PageView].
/// Optionally appends an [actionCard] (e.g., "add photo" button) if the photo count
/// is less than [maxPhotos].
///
/// Includes:
/// - Page indicator (dots with worm effect)
/// - Optional caption below the carousel
class PhotoCarousel extends StatelessWidget {
  /// List of image paths or URLs to display in the carousel.
  final List<String> photoUrls;

  /// Page controller for managing swipes and page transitions.
  final PageController controller;

  /// Optional caption shown below the photo carousel.
  final String? caption;

  /// An optional card (e.g., action button) displayed at the end of the carousel.
  ///
  /// Displayed only if [photoUrls.length] is less than [maxPhotos].
  final Widget? actionCard;

  /// Maximum number of photos allowed before hiding the [actionCard].
  final int maxPhotos;

  /// Creates a [PhotoCarousel] with a list of photos and optional trailing action.
  const PhotoCarousel({
    super.key,
    required this.photoUrls,
    required this.controller,
    this.caption,
    this.actionCard,
    this.maxPhotos = 5,
  });

  @override
  Widget build(BuildContext context) {
    final bool showActionCard =
        photoUrls.length < maxPhotos && actionCard != null;
    final int itemCount = photoUrls.length + (showActionCard ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EA),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: controller,
              itemCount: itemCount,
              allowImplicitScrolling: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index < photoUrls.length) {
                  return PolaroidPhoto(
                    backgroundColor: const Color(0xFFFFF9EA),
                    imagePath: photoUrls[index],
                    showShadow: false,
                    borderWidth: 20,
                  );
                } else {
                  return actionCard ?? const SizedBox.shrink();
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          SmoothPageIndicator(
            controller: controller,
            count: photoUrls.length,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Color(0xFF2E5355),
              dotColor: Color(0xFFB7C4C6),
            ),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              caption!,
              style: GoogleFonts.specialElite(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
