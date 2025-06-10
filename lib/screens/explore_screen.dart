import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/widgets/explore_option.dart';
import 'package:itinereo/widgets/itinereo_appBar.dart';
import 'package:itinereo/widgets/itinereo_bottomBar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.switchScreen,
    required this.switchToDiary,
    required this.onBottomTap,
  });

  final Function() switchScreen;
  final void Function(int index) onBottomTap;
  final Function() switchToDiary;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        'Be Curious!',
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
              buildExploreTile(
                icon: Icons.account_balance,
                label: 'Museum',
                iconBackground: const Color(0xFF5E9C95),
                labelBackground: const Color(0xFFFDF5E6),
              ),
              const SizedBox(height: 10),

              buildExploreTile(
                icon: Icons.draw,
                label: 'Art Gallery',
                iconBackground: const Color(0xFF5E9C95),
                labelBackground: const Color(0xFFFDF5E6),
              ),
              const SizedBox(height: 10),

              buildExploreTile(
                icon: Icons.library_books,
                label: 'Library',
                iconBackground: const Color(0xFF5E9C95),
                labelBackground: const Color(0xFFFDF5E6),
              ),
              const SizedBox(height: 10),

              buildExploreTile(
                icon: Icons.beach_access,
                label: 'Beach',
                iconBackground: const Color(0xFF5E9C95),
                labelBackground: const Color(0xFFFDF5E6),
              ),
              const SizedBox(height: 10),

              buildExploreTile(
                icon: Icons.park,
                label: 'Park',
                iconBackground: const Color(0xFF5E9C95),
                labelBackground: const Color(0xFFFDF5E6),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ItinereoBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) widget.switchScreen();
          if (index == 2) {
            widget.switchScreen();
          }
        },
      ),
    );
  }
}
