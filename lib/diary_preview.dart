import 'package:flutter/material.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/services/diary_service.dart';
import 'package:itinereo/widgets/itinereo_appBar.dart';
import 'package:itinereo/widgets/travel_card.dart';

class DiaryPreview extends StatelessWidget {
  const DiaryPreview({super.key});

  Future<List<DiaryCard>> fetchDiaryCards() {
    return DiaryService().getDiaryCards(
      "AIzaSyBXDRFaSOLLb5z0peibW6wLRk9zfYNQ_O8",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ItinereoAppBar(
        title: "Diary",
        textColor: const Color(0xFFF6E1C4),
        pillColor: const Color(0xFFC97F4F),
        topBarColor: const Color(0xFFD28F3F),
      ),
      backgroundColor: const Color(0xFFF6E1C4),
      body: FutureBuilder<List<DiaryCard>>(
        future: fetchDiaryCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No entries found'));
          }

          final cards = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: cards.length,
            itemBuilder:
                (context, index) => TravelCard(diaryCard: cards[index]),
          );
        },
      ),
    );
  }
}

