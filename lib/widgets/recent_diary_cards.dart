import 'package:flutter/material.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/widgets/horizontal_card.dart';

class RecentDiaryCardsBox extends StatelessWidget {
  final List<DiaryCard> cards;
  final void Function(String entryId) onViewPage;


  const RecentDiaryCardsBox({super.key, required this.cards, required this.onViewPage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            'Your recent memories:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF385A55),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 8, right: 8),
            itemCount: cards.length,
            itemBuilder: (context, index) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width * 0.7,
              child: HorizontalDiaryCard(
                diaryCard: cards[index],
                onViewPage: () { 
                  onViewPage(cards[index].id);
                },
              ),
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 3),
          ),
        ),
      ],
    );
  }
}
