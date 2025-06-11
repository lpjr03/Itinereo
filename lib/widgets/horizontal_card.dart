import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/widgets/safe_local_image.dart';

class HorizontalDiaryCard extends StatelessWidget {
  final DiaryCard diaryCard;
  final VoidCallback onViewPage;
  final bool permission;

  const HorizontalDiaryCard({
    super.key,
    required this.diaryCard,
    required this.onViewPage,
    required this.permission,
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
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SafeLocalImage(path: diaryCard.imageUrl , height: MediaQuery.of(context).size.height * 0.13, 
                width: double.infinity, hasStoragePermission: permission,),
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
                      fontSize: 11,
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
