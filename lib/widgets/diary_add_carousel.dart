import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class DiaryPhotoCarousel extends StatelessWidget {
  final List<String> photoUrls;
  final VoidCallback onAddPhoto;
  final void Function(int index) onRemovePhoto;
  final double height;

  const DiaryPhotoCarousel({
    super.key,
    required this.photoUrls,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        enableInfiniteScroll: false,
        viewportFraction: 1.0,
        enlargeCenterPage: true,
        scrollPhysics: const BouncingScrollPhysics(),
      ),
      items: List.generate(photoUrls.length < 5 ? photoUrls.length + 1 : 5, (
        index,
      ) {
        final isAddCard = index == photoUrls.length && photoUrls.length < 5;

        if (isAddCard) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2D8),
              border: Border.all(color: Color(0xFFD8CCB1), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: IconButton(
                onPressed: onAddPhoto,
                icon: const Icon(
                  Icons.add_a_photo,
                  size: 48,
                  color: Color(0xFF2E5355),
                ),
                splashRadius: 32,
                tooltip: 'Add a new Photo',
              ),
            ),
          );
        }

        final photoUrl = photoUrls[index];
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => Dialog(
                        backgroundColor: Colors.black,
                        insetPadding: const EdgeInsets.all(16),
                        child: InteractiveViewer(
                          child: Image.file(File(photoUrl)),
                        ),
                      ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image:  FileImage(File(photoUrl)) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => onRemovePhoto(index),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
