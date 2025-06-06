import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/services/diary_service.dart';
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
  List<DiaryCard> _diaryCards = [];
  bool _isLoading = false;
  bool _hasMore = true;
QueryDocumentSnapshot<Map<String, dynamic>>? _lastFetchedDocument=null;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoreCardsFromFirebase();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
  if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
      !_isLoading &&
      _hasMore) {
    _loadMoreCardsFromFirebase();
  }
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
          setState(() {});
          if (widget.onBack != null) widget.onBack!();
        },
      ),
      backgroundColor: const Color(0xFFF6E1C4),
      body: ListView.builder(
                controller: _scrollController,
                itemExtent: 300,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _diaryCards.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _diaryCards.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final diaryCard = _diaryCards[index];

                  return Dismissible(
                    key: Key(diaryCard.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: const Color.fromARGB(255, 227, 105, 96),
                      child: const Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.white,
                        size: 80,
                      ),
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
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (direction) async {
                      await DiaryService.instance.deleteEntry(diaryCard.id);
                      setState(() {
                        _diaryCards.removeAt(index);
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
              ),

      bottomNavigationBar: ItinereoBottomBar(
        currentIndex: 2,
        onTap: widget.onBottomTap,
      ),
    );
  }

  Future<void> _loadMoreCardsFromFirebase() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final newDocs = await DiaryService.instance.fetchMoreDiaryEntries(
      lastDocument: _lastFetchedDocument,
      limit: 2,
    );

    if (newDocs.isNotEmpty) {
      _lastFetchedDocument = newDocs.last;

      final newCards =
          newDocs.map((doc) => DiaryCard.fromMap(doc.id, doc.data())).toList();
      setState(() {
        _diaryCards.addAll(newCards);
      });
    } else {
      setState(() {
        _hasMore = false;
      });
    }

    setState(() => _isLoading = false);
  }
}
