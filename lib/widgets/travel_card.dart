import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TravelCard extends StatelessWidget {
  const TravelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      color: const Color.fromARGB(255, 242, 225, 186),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/venice.jpg',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            Text(
              'April 16, 2024',
              style: GoogleFonts.libreBaskerville(
                color: Color(0xFF73370F),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: -0.8,
              ),
            ),
            Text(
              'Venezia',
              style: GoogleFonts.libreBaskerville(
                color: Color(0xFF73370F),
                fontWeight: FontWeight.bold,
                fontSize: 34,
                letterSpacing: -0.8,
                height: 1.5,
              ),
            ),
            Text(
              'Un sogno che diventa realtà...',
              style: GoogleFonts.deliciousHandrawn(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                letterSpacing: -0.8,
                height: 0.8,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  //@todo
                },
                child: Text(
                  'View page',
                  style: GoogleFonts.libreBaskerville(
                    color: Color(0xFF73370F),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
