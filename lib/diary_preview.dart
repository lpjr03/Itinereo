import 'package:flutter/material.dart';
import 'package:itinereo/widgets/itinereo_appBar.dart';
import 'package:itinereo/widgets/travel_card.dart';

class DiaryPreview extends StatelessWidget {
  const DiaryPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ItinereoAppBar(title: "Diary", textColor: Color(0xFFF6E1C4), pillColor: Color(0xFFC97F4F), topBarColor: Color(0xFFD28F3F),
      ),
      backgroundColor: const Color(0xFFF6ECD4),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: 10,
        itemBuilder: (context, index) => const TravelCard(),
      ),
    );
  }
}
