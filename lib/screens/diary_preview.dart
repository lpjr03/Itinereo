import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/itinereo_manager.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:itinereo/widgets/itinereo_appBar.dart';
import 'package:itinereo/widgets/itinereo_bottomBar.dart';
import 'package:itinereo/widgets/travel_card.dart';

class DiaryPreview extends StatelessWidget {
  final void Function(String entryId) onViewPage;
  final VoidCallback? onBack;
  final void Function(int)? onBottomTap;
  const DiaryPreview({super.key, required this.onViewPage, required this.onBack, this.onBottomTap,});
  
  

  Future<List<DiaryCard>> fetchDiaryCards() {
    return LocalDiaryDatabase().getDiaryCardsFromLocalDb(userId: FirebaseAuth.instance.currentUser!.uid, limit: 10, offset: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ItinereoAppBar(
        title: "Diary",
        textColor: const Color(0xFFF6E1C4),
        pillColor: const Color(0xFFC97F4F),
        topBarColor: const Color(0xFFD28F3F),
        isBackButtonVisible: true,
        onBack: onBack,
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
          itemBuilder: (context, index) {
              final diaryCard = cards[index];
              return TravelCard(
                diaryCard: diaryCard,
                onViewPage: () => onViewPage(diaryCard.id),
              );
            },
          );
        },
      ),

      bottomNavigationBar: ItinereoBottomBar(currentIndex: 2, onTap: onBottomTap),
    );
  }
}

