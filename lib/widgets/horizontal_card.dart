import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/widgets/safe_local_image.dart';

/// A horizontally oriented diary preview card displaying an image,
/// date, location, title, and a call-to-action button.
///
/// This card is used to show recent diary entries
/// in a horizontal scrollable list.
///
class HorizontalDiaryCard extends StatelessWidget {
  /// Diary data source containing date, image path, location and title.
  final DiaryCard diaryCard;

  /// Callback executed when the user taps the "View page" button.
  final VoidCallback onViewPage;

  /// Creates a [HorizontalDiaryCard] with the given diary content.
  const HorizontalDiaryCard({
    super.key,
    required this.diaryCard,
    required this.onViewPage,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd('en_US').format(diaryCard.date);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: const Color.fromARGB(255, 255, 244, 217),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 7/1,
                    child:  SafeLocalImage(
                      path: diaryCard.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: GoogleFonts.libreBaskerville(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF73370F),
                ),
              ),
              Text(
                _truncateWithEllipsis(diaryCard.place, 15),
                style: GoogleFonts.libreBaskerville(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF73370F),
                ),
              ),

              Text(
                diaryCard.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.deliciousHandrawn(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: onViewPage,
                  child: Text(
                    'View page',
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF73370F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _truncateWithEllipsis(String text, int maxChars) {
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}..';
  }
}
