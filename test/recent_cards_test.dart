import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itinereo/models/diary_card.dart';

class FakeSafeLocalImage extends StatelessWidget {
  final double height;
  final double width;

  const FakeSafeLocalImage({
    super.key,
    required this.height,
    required this.width,
    required bool hasStoragePermission,
    required String path,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey,
      child: const Icon(Icons.image, color: Colors.white),
    );
  }
}

class TestHorizontalDiaryCard extends StatelessWidget {
  final DiaryCard diaryCard;
  final VoidCallback onViewPage;
  final bool permission;

  const TestHorizontalDiaryCard({
    super.key,
    required this.diaryCard,
    required this.onViewPage,
    required this.permission,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${diaryCard.date.month}/${diaryCard.date.day}/${diaryCard.date.year}';

    return Card(
      child: Column(
        children: [
          FakeSafeLocalImage(
            path: diaryCard.imageUrl,
            height: 100,
            width: 100,
            hasStoragePermission: permission,
          ),
          Text(diaryCard.title),
          Text(diaryCard.place),
          Text(formattedDate),
          TextButton(
            onPressed: onViewPage,
            child: const Text('View page'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('RecentDiaryCardsBox shows cards and triggers callback',
      (WidgetTester tester) async {
    bool tapped = false;

    final fakeCard = DiaryCard(
      id: 'test-id',
      date: DateTime(2024, 6, 1),
      title: 'Test Title',
      place: 'Test Place',
      imageUrl: 'irrelevant.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text(
                    'Your recent memories:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 300,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TestHorizontalDiaryCard(
                            diaryCard: fakeCard,
                            onViewPage: () => tapped = true,
                            permission: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Place'), findsOneWidget);
    expect(find.text('View page'), findsOneWidget);

    await tester.tap(find.text('View page'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
