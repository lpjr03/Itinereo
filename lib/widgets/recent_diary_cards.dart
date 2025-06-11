import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/widgets/horizontal_card.dart';

/// A scrollable horizontal section that displays the most recent diary entries.
///
/// Includes:
/// - A section title
/// - A refresh button
/// - A horizontally scrollable list of [HorizontalDiaryCard]s
///
/// Used to highlight the latest memories saved by the user in the diary.
class RecentDiaryCardsBox extends StatelessWidget {
  /// List of diary entries to display.
  final List<DiaryCard> cards;

  /// Callback triggered when a diary card is tapped.
  /// Receives the entry's [id] as parameter.
  final void Function(String entryId) onViewPage;

  /// Callback triggered when the refresh icon is pressed.
  final VoidCallback onRefresh;

  /// Creates a [RecentDiaryCardsBox] showing a list of recent diary entries.
  const RecentDiaryCardsBox({
    super.key,
    required this.cards,
    required this.onViewPage,
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
              Expanded(
                child: Text(
                  'Your recent memories:',
                  style: GoogleFonts.playpenSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF385A55),
                  ),
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
                  ),
                ),
            separatorBuilder: (_, __) => const SizedBox(width: 3),
          ),
        ),
      ],
    );
  }
}
