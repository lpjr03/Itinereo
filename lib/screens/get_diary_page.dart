import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/widgets/polaroid_photo.dart';
import 'package:itinereo/widgets/text_widget.dart';
import '../../models/diary_entry.dart';
import '../services/diary_service.dart';

class DiaryEntryDetailPage extends StatelessWidget {
  final String entryId;

  const DiaryEntryDetailPage({super.key, required this.entryId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DiaryEntry?>(
        future: DiaryService().getEntryById(entryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final entry = snapshot.data;
          if (entry == null) {
            return const Center(child: Text('Page not found.'));
          }

          return Scaffold(
            backgroundColor: Color(0xFFBBBEBF),
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    height: MediaQuery.of(context).size.height,
                    color: Color(0xFF649991),
                    child: Container(
                      padding: EdgeInsets.all(16),

                      color: Color(0xFFF6E1C4),

                      child: ListView(
                        children: [
                          TextWidget(
                            title: '"${entry.title}"',
                            txtSize: 38,
                            txtColor: Color(0xFF2E5355),
                          ),

                          if (entry.photoUrls.isNotEmpty) ...[
                            Center(
                              child: PolaroidPhoto(
                                imagePath: entry.photoUrls.first,
                                backgroundColor: Colors.grey.shade100,
                                angle: 0,
                                caption: '${_formatDate(entry.date)} • ${entry.latitude}',
                                width: 350,
                              ),
                            ),
                          ],
                          

                          Text(
                            entry.description,
                            style: GoogleFonts.playpenSans(
                              fontSize: 11,
                              letterSpacing: -0.04 * 11,
                              fontWeight: FontWeight.w400, 
                            ),
                            textAlign:
                                TextAlign.center, 
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettagli Voce Diario')),
      body: FutureBuilder<DiaryEntry?>(
        future: DiaryService().getEntryById(entryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final entry = snapshot.data;
          if (entry == null) {
            return const Center(child: Text('Page not found.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Titolo corsivo con virgolette
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${entry.title}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Foto incorniciata
                if (entry.photoUrls.isNotEmpty) ...[
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Image.file(
                        File(entry.photoUrls.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Data e luogo
                Center(
                  child: Text(
                    '${_formatDate(entry.date)} • ${entry.latitude}', //@todo
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Descrizione in box separato
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.description,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }*/

  String _formatDate(DateTime date) {
    return '${_monthDayYear(date)}';
  }

  String _monthDayYear(DateTime date) {
    final month = _monthName(date.month);
    return '$month ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
