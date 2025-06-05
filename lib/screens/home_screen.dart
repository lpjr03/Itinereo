import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/services/google_service.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:itinereo/widgets/itinerary_card.dart';
import 'package:itinereo/widgets/itinereo_appBar.dart';
import 'package:itinereo/widgets/itinereo_bottomBar.dart';
import 'package:itinereo/widgets/recent_diary_cards.dart';
import 'package:itinereo/widgets/suggestion_box.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.switchScreen,
    required this.cachedItineraries,
    required this.setCachedItineraries,
    required this.switchToCustomMap,
    required this.switchToDetailPage,
  });

  final Function() switchScreen;
  final Function(String entryId) switchToDetailPage;
  final Function(List<Marker> markers, String title, {bool polyline})
  switchToCustomMap;
  final Future<List<List<Marker>>>? cachedItineraries;
  final void Function(Future<List<List<Marker>>>) setCachedItineraries;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<List<Marker>>> itineraries;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    if (widget.cachedItineraries != null) {
      itineraries = widget.cachedItineraries!;
    } else {
      itineraries = _loadItineraries();
      widget.setCachedItineraries(itineraries);
    }
  }

  Future<List<List<Marker>>> _loadItineraries() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final entries = await LocalDiaryDatabase().getRecentDiaryEntries(
        userId: userId,
      );
      if (entries.isEmpty) throw Exception("No entries found.");

      return await GoogleService.generateItinerariesFromEntries(entries);
    } on SocketException {
      throw Exception("No connection. Couldn't generate new itineraries.");
    }
  }

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
        child: FutureBuilder<List<List<Marker>>>(
          future: itineraries,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEEEC9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 9,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              'Welcome back, $firstName!',
                              style: GoogleFonts.playpenSans(
                                textStyle: const TextStyle(
                                  fontSize: 25,
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
                                  fontSize: 16,
                                  color: Colors.black87,
                                  letterSpacing: 0.1,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  FutureBuilder<List<DiaryCard>>(
                    future: LocalDiaryDatabase().getDiaryCardsFromLocalDb(
                      userId: FirebaseAuth.instance.currentUser!.uid,
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
                      );
                    },
                  ),
                  const SizedBox(height: 15),
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
                          markers: snapshot.data![index],
                          onTap: () {
                            widget.switchToCustomMap(
                              snapshot.data![index],
                              'Itinerario ${index + 1}',
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
      bottomNavigationBar: ItinereoBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) widget.switchScreen();
        },
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.photos.isDenied || await Permission.storage.isDenied) {
      final status = await [Permission.photos, Permission.storage].request();

      if (status[Permission.photos]?.isDenied == true ||
          status[Permission.storage]?.isDenied == true) {
        throw Exception('Storage permission not granted');
      }
    }
  }
}
