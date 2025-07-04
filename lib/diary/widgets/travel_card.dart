import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:itinereo/models/diary_card.dart';
import 'package:itinereo/shared/widgets/safe_local_image.dart';

/// A stylized horizontal card used to preview a travel diary entry.
///
/// Includes:
/// - Image on the left side, with gradient fade
/// - Title, place, and date on the right
/// - "View page" button at the bottom
///
/// The image is rendered using [SafeLocalImage] with fallback/error handling.
class TravelCard extends StatelessWidget {
  /// Diary data model containing title, date, place, and image path.
  final DiaryCard diaryCard;

  /// Callback triggered when the "View page" button is tapped.
  final VoidCallback onViewPage;

  /// Creates a [TravelCard] representing a single travel diary entry.
  const TravelCard({
    super.key,
    required this.diaryCard,
    required this.onViewPage,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd('en_US').format(diaryCard.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color.fromARGB(255, 255, 244, 217),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.35,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.35,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color.fromARGB(255, 255, 244, 217),
                        Colors.transparent,
                      ],
                      stops: [0.7, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SafeLocalImage(
                    path: diaryCard.imageUrl,
                    verticalLayout: true,
                    showSettingsButton: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: GoogleFonts.libreBaskerville(
                        color: const Color(0xFF73370F),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      diaryCard.place,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.libreBaskerville(
                        color: const Color(0xFF73370F),
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      diaryCard.title,
                      style: GoogleFonts.playpenSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: ElevatedButton.icon(
                        onPressed: onViewPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8C4B2F),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                        ),
                        label: Text(
                          'View page',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playpenSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
