import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ItinereoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color textColor;
  final Color pillColor;
  final Color topBarColor;
  final bool? isBackButtonVisible;
  final VoidCallback? onBack;
  final bool showPill;

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
