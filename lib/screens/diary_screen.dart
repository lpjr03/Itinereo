import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/widgets/bookmark_button.dart';
import 'package:itinereo/widgets/polaroid_photo.dart';

class DiaryScreen extends StatelessWidget {
  final Function() switchToPreview;
  final Function() switchToAddDiaryPage;
  final Function() switchToMapPage;
  final Function() switchToHome;

  const DiaryScreen({
    super.key,
    required this.switchToPreview,
    required this.switchToAddDiaryPage,
    required this.switchToMapPage,
    required this.switchToHome,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return Stack(
              fit: StackFit.expand,
              children: [
                // Background layers
                Container(
                  width: width,
                  height: height,
                  color: const Color(0xFFBBBEBF), // Gray background
                ),
                Positioned(
                  right: 22,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: const BoxDecoration(
                      color: Color(0xFFAB5319),
                      boxShadow: [
                        BoxShadow(color: Colors.black87, blurRadius: 10),
                      ],
                    ),
                  ),
                ),

                // Bookmarks
                Positioned(
                  top: 20,
                  right: 4,
                  child: Column(
                    children: [
                      BookMark(
                        onPressed: switchToMapPage,
                        icon: Icons.public_rounded,
                        label: "Map",
                        textAndIconColor: Colors.white,
                        backgroundColor: const Color(0xFF95A86E),
                      ),
                      const SizedBox(height: 15),
                      BookMark(
                        onPressed: switchToPreview,
                        icon: Icons.photo_album_outlined,
                        label: "Diary",
                        textAndIconColor: Colors.white,
                        backgroundColor: const Color(0xFFC97F4F),
                      ),
                      const SizedBox(height: 15),
                      BookMark(
                        onPressed: switchToHome,
                        icon: Icons.home,
                        label: "Home",
                        textAndIconColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 227, 105, 96),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  right: 45,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: const BoxDecoration(
                      color: Color(0xFF385A55),
                      boxShadow: [
                        BoxShadow(color: Colors.black87, blurRadius: 10),
                      ],
                    ),
                  ),
                ),

                // Top Left Back Button
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 40,
                      color: Color(0xFFA75119),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Central Diary Cover
                Positioned(
                  top: 20,
                  right: 60,
                  left: 18,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECDABC),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFD8CCB1),
                        width: 8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Title Block
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          height: height * 0.18,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9EDD2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD8CCB1),
                              width: 9,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Travel\nJournal',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playpenSans(
                              textStyle: TextStyle(
                                height: 0.76,
                                fontSize: width * 0.12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2E5255),
                              ),
                            ),
                          ),
                        ),

                        // App name
                        Container(
                          width: width * 0.35,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD79848),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Itinerèo',
                            style: GoogleFonts.libreBaskerville(
                              textStyle: TextStyle(
                                fontSize: width * 0.06,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFEEEC9),
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),
                        ),

                        // Polaroids & Graphics
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          height: height * 0.45,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 15,
                                left: 15,
                                child: Transform.rotate(
                                  angle: -0.1,
                                  child: Image.asset(
                                    'assets/images/paperPlane.png',
                                    height: height * 0.30,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: height * 0.13,
                                right: 0,
                                child: Transform.rotate(
                                  angle: -0.1,
                                  child: Image.asset(
                                    'assets/images/luggage.png',
                                    height: height * 0.1,
                                  ),
                                ),
                              ),

                              Positioned(
                                bottom: 0,
                                left: 10,
                                child: Transform.rotate(
                                  angle: 0,
                                  child: Image.asset(
                                    'assets/images/positionPin.png',
                                    height: height * 0.065,
                                  ),
                                ),
                              ),

                              Positioned(
                                bottom: 0,
                                right: 20,
                                height: height * 0.15,
                                child: PolaroidPhoto(
                                  imagePath: 'assets/images/venice.jpg',
                                  backgroundColor: const Color(0xFFF9EDD2),
                                  angle: 0.25,
                                  isAsset: true,
                                ),
                              ),
                              Positioned(
                                top: 100,
                                left: 0,
                                height: height * 0.22,
                                child: PolaroidPhoto(
                                  imagePath: 'assets/images/florence.jpg',
                                  backgroundColor: const Color(0xFFF9EDD2),
                                  angle: -0.12,
                                  isAsset: true,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 0,
                                height: height * 0.20,
                                child: PolaroidPhoto(
                                  imagePath: 'assets/images/colosseum.jpg',
                                  backgroundColor: const Color(0xFFF9EDD2),
                                  angle: 0.17,
                                  isAsset: true,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 15),
                          child: Text(
                            'New adventure?\nDrop it here!',
                            style: GoogleFonts.playpenSans(
                              textStyle: TextStyle(
                                fontSize: width * 0.062,
                                color: const Color(0xFF2E5255),
                                fontWeight: FontWeight.w500,
                                height: 1,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            onPressed: switchToAddDiaryPage,
                            backgroundColor: const Color(0xFFE8A951),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Color(0xFFA75119),
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
