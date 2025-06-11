import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/widgets/photo_carousel.dart';
import '../../models/diary_entry.dart';
import '../services/diary_service.dart';

class DiaryEntryDetailPage extends StatelessWidget {
  final String entryId;
  final Function() onBack;

  DiaryEntryDetailPage({
    super.key,
    required this.entryId,
    required this.onBack,
  });
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: FutureBuilder<DiaryEntry?>(
        future: DiaryService().getEntryById(entryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final entry = snapshot.data;
          if (entry == null) {
            return const Center(child: Text('Page not found.'));
          }

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Color(0xFF95A86E),
              statusBarIconBrightness: Brightness.light,
            ),
          );

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF95A86E),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6E1C4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded,size: 30,),
                                  color: const Color(0xFF2E5355),
                                  onPressed: () => onBack(),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Itinerèo',
                                      style: GoogleFonts.libreBaskerville(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD28F3F),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(Icons.photo_album_outlined,
                                  color: const Color(0xFF2E5355),
                                  size: 35,
                                )
                              ],
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6ECD4),
                                border: Border.all(
                                  color: const Color(0xFFD8CCB1),
                                  width: 4,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '"${entry.title}"',
                                    style: GoogleFonts.deliciousHandrawn(
                                      textStyle: const TextStyle(
                                        fontSize: 25,
                                        //height: 1.7,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E5355),
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            if (entry.photoUrls.isNotEmpty) ...[
                              if (entry.photoUrls.isNotEmpty)
                                PhotoCarousel(
                                  photoUrls: entry.photoUrls,
                                  controller: _pageController,
                                  caption:
                                      '${_formatDate(entry.date)} • ${entry.location}',
                                  maxPhotos: 5,
                                ),
                            ],

                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.all(16.0),
                              constraints: const BoxConstraints(minHeight: 120),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5DD),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '« ${entry.description} »',
                                style: GoogleFonts.playpenSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return _monthDayYear(date);
  }

  String _monthDayYear(DateTime date) {
    final month = _monthName(date.month);
    return '$month ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
