import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/widgets/travel_card.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('TravelCard displays content and triggers callback', (
    WidgetTester tester,
  ) async {
    // Flag to check if the callback is triggered
    bool tapped = false;

    // Fake data for testing
    final fakeDiaryCard = DiaryCard(
      id: '1',
      date: DateTime(2024, 6, 1),
      title: 'A walk through the hills',
      place: 'Tuscany',
      imageUrl: 'test', // Local path, but we won't load it during the test
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 1280), // Define screen size for MediaQuery usage
          ),
          child: Scaffold(
            body: TravelCard(
              diaryCard: fakeDiaryCard,
              onViewPage: () {
                tapped = true;
              },
            ),
          ),
        ),
      ),
    );

    // Verifica che le informazioni di base siano presenti
    expect(find.text('Tuscany'), findsOneWidget);
    expect(find.text('A walk through the hills'), findsOneWidget);
    expect(
      find.text(DateFormat.yMMMMd('en_US').format(fakeDiaryCard.date)),
      findsOneWidget,
    );

    // Simula il tap sul pulsante "View page"
    await tester.tap(find.text('View page'));
    await tester.pump();

    // Verifica che il callback sia stato eseguito
    expect(tapped, isTrue);
  });
}
