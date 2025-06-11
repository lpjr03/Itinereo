import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom app bar for the Itinereo app, featuring:
/// - Optional back button
/// - Colored top bar and bottom section
/// - Centered pill-style title
///
/// The app bar height is fixed to 90 pixels.
/// It modifies the system status bar color and icon brightness as well.
class ItinereoAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Main title displayed in the center pill.
  final String title;

  /// Color of the title text inside the pill.
  final Color textColor;

  /// Background color of the pill containing the title.
  final Color pillColor;

  /// Color of the top bar section (55px height).
  final Color topBarColor;

  /// Whether to display the back button on the left.
  final bool? isBackButtonVisible;

  /// Callback executed when the back button is pressed.
  final VoidCallback? onBack;

  /// Controls whether the title pill is shown.
  final bool showPill;

  /// Creates an [ItinereoAppBar] widget with customizable sections and optional back navigation
  const ItinereoAppBar({
    super.key,
    required this.title,
    required this.textColor,
    required this.pillColor,
    required this.topBarColor,
    this.isBackButtonVisible = false,
    this.onBack,
    this.showPill = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    /// Set the status bar style to match the top bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: topBarColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Container(
                height: 55,
                color: topBarColor,
                alignment: Alignment.centerLeft,
                child:
                    (isBackButtonVisible ?? false)
                        ? Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: onBack,
                            alignment: Alignment.centerLeft,
                          ),
                        )
                        : const SizedBox(),
              ),
              Container(height: 35, color: const Color(0xFFF6E1C4)),
            ],
          ),

          if (showPill)
            Positioned(
              top: 35,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
