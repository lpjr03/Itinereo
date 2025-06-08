import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/widgets/horizontal_card.dart';

class RecentDiaryCardsBox extends StatelessWidget {
  final List<DiaryCard> cards;
  final void Function(String entryId) onViewPage;
  final bool permission;
  final VoidCallback onRefresh;

  const RecentDiaryCardsBox({
    super.key,
    required this.cards,
    required this.onViewPage,
    required this.permission,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your recent memories:',
                style: GoogleFonts.playpenSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF385A55),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                color: Color(0xFF385A55),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 8, right: 8),
            itemCount: cards.length,
            itemBuilder:
                (context, index) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: HorizontalDiaryCard(
                    diaryCard: cards[index],
                    onViewPage: () {
                      onViewPage(cards[index].id);
                    },
                    permission: permission,
                  ),
                ),
            separatorBuilder: (_, __) => const SizedBox(width: 3),
          ),
        ),
      ],
    );
  }
}
