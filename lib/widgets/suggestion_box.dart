import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuggestedItinerariesBox extends StatelessWidget {
  final List<Widget> cards;

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
            color: Colors.black.withOpacity(0.05),
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
            style: GoogleFonts.libreBaskerville(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF385A55),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: cards[index],
            ),
          ),
        ],
      ),
    );
  }
}
