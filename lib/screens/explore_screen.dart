import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/exceptions/location_exceptions.dart';
import 'package:itinereo/services/geolocator_service.dart';
import 'package:itinereo/widgets/explore_option.dart';
import 'package:itinereo/widgets/itinereo_appBar.dart';
import 'package:itinereo/widgets/itinereo_bottomBar.dart';
import 'package:itinereo/widgets/snackbar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.onBottomTap});

  final void Function(int index) onBottomTap;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedIndex = 0;

  final List<(String, IconData)> options = const [
    ('Museum', Icons.account_balance),
    ('Art Gallery', Icons.draw),
    ('Library', Icons.library_books),
    ('Beach', Icons.beach_access),
    ('Park', Icons.park),
  ];

  final Map<String, String> typeMapping = const {
    'Museum': 'museum',
    'Art Gallery': 'art_gallery',
    'Library': 'library',
    'Beach': 'tourist_attraction',
    'Park': 'park',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ItinereoAppBar(
        title: 'Explore',
        textColor: const Color(0xFFFEEEC9),
        pillColor: const Color(0xFF9D633D),
        topBarColor: const Color(0xFFC97F4F),
      ),
      backgroundColor: const Color(0xFFF6E1C4),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              children: [
                Text(
                  'Be Curious!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playpenSans(
                    textStyle: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9D633D),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore New Horizons!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.libreBaskerville(
                    textStyle: const TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                      letterSpacing: 0.1,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What are you up to today?',
                    style: GoogleFonts.playpenSans(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9D633D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ...options.map((entry) {
                  final (label, icon) = entry;
                  final tileWidth =
                      MediaQuery.of(context).size.width.clamp(300.0, 700.0) *
                      0.55;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Center(
                      child: buildExploreTile(
                        icon: icon,
                        label: label,
                        iconBackground: const Color(0xFF5E9C95),
                        labelBackground: const Color(0xFFFDF5E6),
                        width: tileWidth,
                        onPressed: () async {
                          try {
                            final position =
                                await GeolocatorService().getCurrentLocation();
                            final mapPage = await GeolocatorService()
                                .getNearbyPlacesMap(
                                  position: position,
                                  type: label,
                                  title: label,
                                  onBack: () => Navigator.pop(context),
                                );
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => mapPage),
                              );
                            }
                          } on LocationServicesDisabledException {
                            if (mounted) {
                              ItinereoSnackBar.show(
                                context,
                                'Location services are disabled. Please enable them in your device settings.',
                              );
                            }
                          } on LocationPermissionDeniedException {
                            if (mounted) {
                              ItinereoSnackBar.show(
                                context,
                                'Location permission denied. Please grant access to continue.',
                              );
                            }
                          } on LocationPermissionPermanentlyDeniedException {
                            if (mounted) {
                              ItinereoSnackBar.show(
                                context,
                                'Location permission permanently denied. Enable it from system settings.',
                              );
                            }
                          } on SocketException {
                            if (mounted) {
                              ItinereoSnackBar.show(
                                context,
                                'Network error. Please check your internet connection.',
                              );
                            }
                          } on PlacesApiException {
                            if (mounted) {
                              ItinereoSnackBar.show(
                                context,
                                'No relevant places found nearby.',
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
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
