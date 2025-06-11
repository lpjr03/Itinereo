import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itinereo/models/diary_card.dart';
import 'package:itinereo/services/diary_service.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/services/local_storage_service.dart';
import 'package:itinereo/home_page/widgets/itinerary_card.dart';
import 'package:itinereo/shared/widgets/app_bar.dart';
import 'package:itinereo/shared/widgets/bottom_bar.dart';
import 'package:itinereo/home_page/widgets/recent_cards.dart';
import 'package:itinereo/home_page/widgets/suggestion_box.dart';

/// The main home screen of the Itinerèo app.
///
/// Displays a welcome message, recent diary entries,
/// and suggested itineraries based on previously logged entries.
/// It also provides navigation to detailed diary views and custom maps.
class HomeScreen extends StatefulWidget {
  /// Callback to navigate to the detail view of a diary entry.
  final Function(String entryId) switchToDetailPage;

  /// Callback to navigate to a custom map view with markers and optional polyline.
  final Function(List<Marker> markers, String title, {bool polyline})
  switchToCustomMap;

  /// A cached list of itineraries to prevent recomputation.
  final Future<List<Map<String, dynamic>>>? cachedItineraries;

  /// Setter to update the cached itineraries in the parent state.
  final void Function(Future<List<Map<String, dynamic>>>) setCachedItineraries;

  /// Callback to handle bottom navigation taps.
  final void Function(int index) onBottomTap;

  /// Creates a [HomeScreen] widget.
  const HomeScreen({
    super.key,
    required this.cachedItineraries,
    required this.setCachedItineraries,
    required this.switchToCustomMap,
    required this.switchToDetailPage,
    required this.onBottomTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The state associated with [HomeScreen].
///
/// Manages loading of itineraries, displaying welcome text,
/// recent entries, and navigating to other sections.
class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> itineraries;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    if (widget.cachedItineraries != null) {
      // Use cached itineraries if available.
      itineraries = widget.cachedItineraries!;
    } else {
      // Otherwise, load new itineraries and cache them.
      itineraries = _loadItineraries();
      widget.setCachedItineraries(itineraries);
    }
  }

  /// Loads itineraries from diary entries using [GoogleService].
  ///
  /// If no entries are found or connection is absent, it throws an exception.
  Future<List<Map<String, dynamic>>> _loadItineraries() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final entries = await LocalDiaryDatabase().getAllEntries(userId: userId);
      if (entries.isEmpty) throw Exception("No entries found.");
      return await GoogleService.generateItinerariesFromEntries(entries);
    } catch (e) {
      throw Exception("No connection. Could not generate itineraries.");
    }
  }

  /// Refreshes itineraries and updates the state and parent cache.
  void refreshItineraries() {
    final newItineraries = _loadItineraries();
    setState(() {
      itineraries = newItineraries;
      widget.setCachedItineraries(newItineraries);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final fullName = user?.displayName ?? 'Traveler';
    final firstName = fullName.split(' ').first;

    return Scaffold(
      appBar: ItinereoAppBar(
        title: 'Itinerèo',
        textColor: const Color(0xFFF6E1C4),
        pillColor: const Color(0xFF385A55),
        topBarColor: const Color(0xFF506636),
      ),
      backgroundColor: const Color(0xFFF6E1C4),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: itineraries,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Welcome text section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          'Good to see you, $firstName!',
                          style: GoogleFonts.playpenSans(
                            textStyle: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF385A55),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          textAlign: TextAlign.center,
                          'Ready for a new adventure?',
                          style: GoogleFonts.libreBaskerville(
                            textStyle: const TextStyle(
                              fontSize: 17,
                              color: Colors.black87,
                              letterSpacing: 0.1,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Shows the five most recent diary entries.
                  FutureBuilder<List<DiaryCard>>(
                    future: DiaryService.instance.getDiaryCards(
                      limit: 5,
                      offset: 0,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const SizedBox();
                      }

                      return RecentDiaryCardsBox(
                        cards: snapshot.data!,
                        onViewPage: widget.switchToDetailPage,
                        onRefresh: () {
                          refreshItineraries();
                          setState(() {});
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  /// Handles itinerary suggestions display and states
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const CircularProgressIndicator()
                  else if (snapshot.hasError)
                    Center(
                      child: Text(
                        snapshot.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.libreBaskerville(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF385A55),
                        ),
                      ),
                    )
                  else if (!snapshot.hasData || snapshot.data!.isEmpty)
                    Center(
                      child: Text(
                        'No itineraries available. Please add diary entries to generate itineraries.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.libreBaskerville(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF385A55),
                        ),
                      ),
                    )
                  else
                    SuggestedItinerariesBox(
                      cards: List.generate(snapshot.data!.length, (index) {
                        return ItineraryCard(
                          markers: snapshot.data![index]['markers'],
                          title: snapshot.data![index]['title'],
                          onTap: () {
                            widget.switchToCustomMap(
                              snapshot.data![index]['markers'],
                              snapshot.data![index]['title'],
                              polyline: true,
                            );
                          },
                        );
                      }),
                    ),
                ],
              ),
            );
          },
        ),
      ),

      /// Bottom navigation bar for the main app sections.
      bottomNavigationBar: ItinereoBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          widget.onBottomTap(index);
        },
      ),
    );
  }
}
