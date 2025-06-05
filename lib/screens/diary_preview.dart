import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/services/diary_service.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:itinereo/widgets/itinereo_appBar.dart';
import 'package:itinereo/widgets/itinereo_bottomBar.dart';
import 'package:itinereo/widgets/travel_card.dart';

class DiaryPreview extends StatefulWidget {
  final void Function(String entryId) onViewPage;
  final VoidCallback? onBack;
  final void Function(int)? onBottomTap;

  const DiaryPreview({
    super.key,
    required this.onViewPage,
    required this.onBack,
    this.onBottomTap,
  });

  @override
  State<DiaryPreview> createState() => _DiaryPreviewState();
}

class _DiaryPreviewState extends State<DiaryPreview> {
  late Future<List<DiaryCard>> _futureDiaryCards;

  @override
  void initState() {
    super.initState();
    _loadDiaryCards();
  }

  void _loadDiaryCards() {
    _futureDiaryCards = LocalDiaryDatabase().getDiaryCardsFromLocalDb(
      userId: FirebaseAuth.instance.currentUser!.uid,
      limit: 10,
      offset: 0,
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
        isBackButtonVisible: true,
        onBack: () {
          _loadDiaryCards(); // Reload data when back button pressed
          setState(() {});
          if (widget.onBack != null) widget.onBack!();
        },
      ),
      backgroundColor: const Color(0xFFF6E1C4),
      body: FutureBuilder<List<DiaryCard>>(
        future: _futureDiaryCards,
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
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final diaryCard = cards[index];

              return Dismissible(
                key: Key(diaryCard.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: const Color.fromARGB(255, 227, 105, 96),
                  child: const Icon(Icons.delete_sweep_outlined, color: Colors.white, size: 80,),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Entry'),
                          content: const Text(
                            'Are you sure you want to delete this diary entry?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );
                },
                onDismissed: (direction) async {
                  await DiaryService.instance.deleteEntry(diaryCard.id);
                  setState(() {
                    cards.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entry deleted')),
                  );
                },
                child: TravelCard(
                  diaryCard: diaryCard,
                  onViewPage: () => widget.onViewPage(diaryCard.id),
                ),
              );
            },
          );

        },
      ),
      bottomNavigationBar: ItinereoBottomBar(
        currentIndex: 2,
        onTap: widget.onBottomTap,
      ),
    );
  }
}


