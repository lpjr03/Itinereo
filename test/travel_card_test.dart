import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/widgets/travel_card.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('TravelCard displays content and triggers callback',
      (WidgetTester tester) async {
    bool tapped = false;

    final fakeDiaryCard = DiaryCard(
      id: '1',
      date: DateTime(2024, 6, 1),
      title: 'A walk through the hills',
      place: 'Tuscany',
      imageUrl: 'test',
    );

    // PNG 1x1 white pixel, base64 encoded
    final pngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9YlpMYwAAAAASUVORK5CYII=';
    final imageBytes = base64Decode(pngBase64);
    final fakeImage = MemoryImage(Uint8List.fromList(imageBytes));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TravelCard(
            diaryCard: fakeDiaryCard,
            onViewPage: () => tapped = true,
            imageProvider: fakeImage,
          ),
        ),
      ),
    );

    expect(find.text('Tuscany'), findsOneWidget);
    expect(find.text('A walk through the hills'), findsOneWidget);
    expect(find.text(DateFormat.yMMMMd('en_US').format(fakeDiaryCard.date)),
        findsOneWidget);

    await tester.tap(find.text('View page'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
