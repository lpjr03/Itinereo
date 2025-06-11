import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/widgets/photo_carousel.dart';
import '../../models/diary_entry.dart';
import '../services/diary_service.dart';

/// A screen that displays detailed information for a specific diary entry.
///
/// Shows the title, description, formatted date, location, and a photo carousel
/// if available. Uses a custom back button to return to the previous screen.
/// This widget is built using a `FutureBuilder` to asynchronously fetch data
/// from the `DiaryService` based on the given [entryId].
class DiaryEntryDetailPage extends StatelessWidget {
  /// The unique ID of the diary entry to be displayed.
  final String entryId;

  /// Callback to navigate back from the detail view.
  final Function() onBack;

  /// Page controller for the photo carousel.
  final PageController _pageController = PageController();

  DiaryEntryDetailPage({
    super.key,
    required this.entryId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      // Loads the diary entry by ID using a FutureBuilder.
      body: FutureBuilder<DiaryEntry?>(
        future: DiaryService().getEntryById(entryId),
        builder: (context, snapshot) {
          // Show loading spinner while waiting for data.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message if the request failed.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entry = snapshot.data;
          if (entry == null) {
            return const Center(child: Text('Page not found.'));
          }

          // Change status bar appearance.
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Color(0xFF95A86E),
              statusBarIconBrightness: Brightness.light,
            ),
          );

          // Build the layout once data is available.
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6E1C4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header with back button and app title.
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 30,
                                  ),
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
                                Icon(
                                  Icons.photo_album_outlined,
                                  color: const Color(0xFF2E5355),
                                  size: 35,
                                ),
                              ],
                            ),

                            // Title of the diary entry.
                            Container(
                              padding: const EdgeInsets.symmetric(
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

                            // Photo carousel if there are photos.
                            if (entry.photoUrls.isNotEmpty)
                              PhotoCarousel(
                                photoUrls: entry.photoUrls,
                                controller: _pageController,
                                caption:
                                    '${_formatDate(entry.date)} • ${entry.location}',
                                maxPhotos: 5,
                              ),

                            // Description box.
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.all(16.0),
                              constraints: const BoxConstraints(minHeight: 120),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5DD),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
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

  /// Formats a [DateTime] into a readable string, e.g., "May 10, 2025".
  String _formatDate(DateTime date) {
    return _monthDayYear(date);
  }

  /// Converts a [DateTime] into the "Month Day, Year" format.
  String _monthDayYear(DateTime date) {
    final month = _monthName(date.month);
    return '$month ${date.day}, ${date.year}';
  }

  /// Maps a numeric month to its English name.
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
