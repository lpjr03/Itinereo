import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itinereo/widgets/polaroid_photo.dart';

class DiaryPhotoCarousel extends StatelessWidget {
  final List<String> photoUrls;
  final VoidCallback onAddPhoto;
  final void Function(String photoPath) onRemovePhoto;
  final double height;

  const DiaryPhotoCarousel({
    super.key,
    required this.photoUrls,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: PageScrollPhysics(),

        padding: EdgeInsets.symmetric(vertical: 10),
        itemCount: photoUrls.length < 5 ? photoUrls.length + 1 : 5,
        itemBuilder: (context, index) {
          final isAddCard = index == photoUrls.length && photoUrls.length < 5;

          if (isAddCard) {
            return Container(
              width: 325,
              margin: EdgeInsets.symmetric(horizontal: 4),

              decoration: BoxDecoration(
                color: const Color(0xFFFFF2D8),
                border: Border.all(color: Colors.white, width: 20),
              ),
              child: Center(
                child: IconButton(
                  onPressed: onAddPhoto,
                  icon: const Icon(
                    Icons.add_a_photo,
                    size: 90,
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
              FilledButton(
                onPressed: () {
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
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: PolaroidPhoto(
                  imagePath: photoUrl,
                  backgroundColor: const Color(0xFFFFF2D8),
                  caption: 'Photo ${index + 1}/5',
                  width: 325,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    onRemovePhoto(photoUrls[index]);
                  },
                  tooltip: 'Remove photo',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.grey),
                    shape: WidgetStateProperty.all(CircleBorder()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
