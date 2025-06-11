import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A styled container that displays a list of suggested itineraries.
///
/// - Displays a section title
/// - Renders a vertical list of itinerary card widgets
///
/// The list of [cards] can include custom widgets such as itinerary previews.
class SuggestedItinerariesBox extends StatelessWidget {
  /// The list of widgets to display as suggested itineraries.
  ///
  /// Typically each item is a custom card widget like [ItineraryCard].
  final List<Widget> cards;

  /// Creates a [SuggestedItinerariesBox] with the provided list of [cards].
  const SuggestedItinerariesBox({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBCB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested itineraries:',
            style: GoogleFonts.playpenSans(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF385A55),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: cards[index],
                ),
          ),
        ],
      ),
    );
  }
}
