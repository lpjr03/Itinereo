import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:itinereo/widgets/polaroid_photo.dart';

class PhotoCarousel extends StatelessWidget {
  final List<String> photoUrls;
  final PageController controller;
  final String? caption;
  final Widget? actionCard;
  final int maxPhotos;

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
    final bool showActionCard = photoUrls.length < maxPhotos;
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


