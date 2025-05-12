import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/add_diary_page.dart';

class DiaryScreen extends StatelessWidget {
  final Function() switchToPreview;
  final Function() switchToAddDiaryPage;

  const DiaryScreen({
    super.key,
    required this.switchToPreview,
    required this.switchToAddDiaryPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Gray Page
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: const Color(0xFFBBBEBF)),
          ),

          // Orange Page
          Positioned(
            right: 22,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: const Color(0xFFAB5319),
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
            top: 33,
            right: 4,
            child: Column(
              children: [
                //Map Bookmark
                BookMark(
                  onPressed:(){
                    //@todo
                  },
                  icon: Icons.public_rounded,
                  label: "Map",
                  textAndIconColor: Color(0xFFFFFFFF),
                  backgroundColor: Color(0xFF95A86E),
                ),

                //Journal Preview Bookmark
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: BookMark(
                    onPressed: switchToPreview,
                    icon: Icons.photo_album_outlined,
                    label: "Diary",
                    textAndIconColor: Color(0xFFFFFFFF),
                    backgroundColor: Color(0xFFC97F4F),
                  ),
                ),
              ],
            ),
          ),

          //Dark Green Page
          Positioned(
            right: 45,
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

          // Beige Page -> Diary Cover
          Positioned(
            top: 20,
            right: 60,
            left: 18,
            bottom: 20,

            child: Container(
              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: Color(0xFFECDABC),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Color(0xFFD8CCB1), width: 8),
              ),

              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 15, left: 15, right: 15),
                      alignment: Alignment.center,
                      height: 125,

                      decoration: BoxDecoration(
                        color: Color(0xFFF9EDD2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFD8CCB1), width: 9),
                      ),
                      child: Center(
                        child: Text(
                          ' Travel\nJournal',
                          style: GoogleFonts.playpenSans(
                            textStyle: TextStyle(
                              height: 0.76,
                              fontSize: 50,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E5255),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 15),
                      width: 140,

                      decoration: BoxDecoration(
                        color: Color(0xFFD79848),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Itinerèo',
                          style: GoogleFonts.libreBaskerville(
                            textStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFEEEC9),
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      height: 480,
                      width: 330,

                      child: Stack(
                        children: [
                          Positioned(
                            top: 15,
                            left: 0,

                            child: Transform.rotate(
                              angle: -0.1,
                              child: Image.asset(
                                'assets/images/paperPlane.png',
                                height: 260,
                              ),
                            ),
                          ),

                          Positioned(
                            top: 190,
                            right: 0,

                            child: Transform.rotate(
                              angle: -0.1,
                              child: Image.asset(
                                'assets/images/luggage.png',
                                height: 90,
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 80,
                            right: 5,

                            child: PolaroidPhoto(
                              imagePath: 'assets/images/venice.jpg',
                              backgroundColor: Color(0xFFF9EDD2),
                              angle: 0.25,
                              height: 130,
                            ),
                          ),

                          Positioned(
                            top: 100,
                            //bottom: 30,
                            child: PolaroidPhoto(
                              imagePath: 'assets/images/florence.jpg',
                              backgroundColor: Color(0xFFF9EDD2),
                              angle: -0.12,
                              height: 180,
                            ),
                          ),

                          Positioned(
                            top: 10,
                            right: 0,

                            child: PolaroidPhoto(
                              imagePath: 'assets/images/colosseum.jpg',
                              backgroundColor: Color(0xFFF9EDD2),
                              angle: 0.17,
                              height: 150,
                            ),
                          ),

                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'New adventure?\nDrop it here!',
                              style: GoogleFonts.playpenSans(
                                textStyle: TextStyle(
                                  fontSize: 25,
                                  color: Color(0xFF2E5255),
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(context, switchToAddDiaryPage());
                        },

                        backgroundColor: Color(0xFFE8A951),
                        child: Icon(
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
          ),

          Positioned(
            top: 20,
            left: 17,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFFA75119), size: 45),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookMark extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          children: [
            Icon(icon, size: 37, color: textAndIconColor),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children:
                    label.split('').map((lettera) {
                      return Text(
                        lettera,
                        style: GoogleFonts.playpenSans(
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: textAndIconColor,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
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
    required this.height,
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
