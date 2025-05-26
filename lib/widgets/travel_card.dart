import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:itinereo/models/card_entry.dart';

class TravelCard extends StatelessWidget {
  final DiaryCard diaryCard;

  const TravelCard({super.key, required this.diaryCard});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd('en_US').format(diaryCard.date);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      color: const Color.fromARGB(255, 255, 244, 217),
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
              child: Image.file(
                File(diaryCard.imageUrl),
                fit: BoxFit.cover,
                height: 180,
                width: double.infinity,
              ),
            ),
            Text(
              formattedDate,
              style: GoogleFonts.libreBaskerville(
                color: Color(0xFF73370F),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: -0.8,
              ),
            ),
            Text(
              diaryCard.place,
              style: GoogleFonts.libreBaskerville(
                color: Color(0xFF73370F),
                fontWeight: FontWeight.bold,
                fontSize: 34,
                letterSpacing: -0.8,
                height: 1.5,
              ),
            ),
            Text(
              diaryCard.title,
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
