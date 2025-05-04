import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen(this.switchScreen, {super.key});

  final Function() switchScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Gray Page
          Positioned(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: const Color(0xFFBBBEBF)),
            ),
          ),

          //Dark Green Page
          Positioned(
            right: 10,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: const Color(0xFF385A55),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),

          // Orange Page
          Positioned(
            right: 23,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 186, 97, 72),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 4,
            child: Column(
              children: [
                //Map Bookmark
                BookMark(
                  onPressed: switchScreen,
                  icon: Icons.public_rounded,
                  label: "Map",
                  textAndIconColor: Color(0xFF2E5255),
                  backgroundColor: Color(0xFF95A86E),
                ),

                //Journal Preview Bookmark
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: BookMark(
                    onPressed: switchScreen,
                    icon: Icons.photo_album_outlined,
                    label: "Diary",
                    textAndIconColor: Color.fromARGB(255, 54, 53, 66),
                    backgroundColor: Color(0xFF6E6D8A),
                  ),
                ),
              ],
            ),
          ),

          // Beige Page -> Diary Cover
          Positioned(
            right: 45,
            child: Container(
              alignment: Alignment.center,

              width: MediaQuery.of(context).size.width - 40,
              height: MediaQuery.of(context).size.height,

              decoration: BoxDecoration(
                color: Color(0xFFECDABC),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 190,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Color(0xFFD79848),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: Text(
                          'Itinerèo',
                          style: GoogleFonts.libreBaskerville(
                            textStyle: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E5255),
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        width: 346,
                        height: 190,
                        decoration: BoxDecoration(
                          color: Color(0xFFF9EDD2),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            ' Travel\nJournal',
                            style: GoogleFonts.deliciousHandrawn(
                              textStyle: TextStyle(
                                height: 0.7,
                                fontSize: 92,
                                color: Color(0xFF2E5255),
                                letterSpacing: -4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 450,
            left: 30,
            child: PolaroidPhoto(
              imagePath: 'assets/images/florence.jpg',
              backgroundColor: Color(0xFFF9EDD2),
              angle: -0.12,
              height: 200,
            ),
          ),

          Positioned(
            top: 370,
            left: 185,
            child: PolaroidPhoto(
              imagePath: 'assets/images/colosseum.jpg',
              backgroundColor: Color(0xFFF9EDD2),
              angle: 0.17,
              height: 155,
            ),
          ),
        ],
      ),
    );
  }
}

class BookMark extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon; // ✅ Tipo corretto per l'icona
  final String label;
  final Color textAndIconColor;
  final Color backgroundColor;

  const BookMark({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.textAndIconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 37, color: textAndIconColor),
          Padding(
            padding: EdgeInsets.all(4),
            child: Column(
              children:
                  label.split('').map((lettera) {
                    return Text(
                      lettera,
                      style: GoogleFonts.specialElite(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: textAndIconColor,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class PolaroidPhoto extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final double angle;
  final double height;

  const PolaroidPhoto({
    super.key,
    required this.imagePath,
    required this.backgroundColor,
    required this.angle,
    required this.height
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
           boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Image.asset(imagePath, height: height),
      ),
    );
  }
}
