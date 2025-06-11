import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinereo/models/diary_card.dart';
import 'package:itinereo/services/diary_service.dart';
import 'package:itinereo/shared/widgets/alert.dart';
import 'package:itinereo/shared/widgets/app_bar.dart';
import 'package:itinereo/shared/widgets/bottom_bar.dart';
import 'package:itinereo/shared/widgets/snackbar.dart';
import 'package:itinereo/diary/widgets/travel_card.dart';

/// A screen that previews the user's diary entries in a scrollable list.
///
/// This screen displays [DiaryCard]s fetched from Firebase (or a local fallback).
/// Users can:
/// - Tap on a diary card to view the full entry via [onViewPage].
/// - Swipe to delete an entry with confirmation.
/// - Load more entries with pagination using Firestore's query cursor.
///
/// It also shows a custom [ItinereoAppBar] and a persistent [ItinereoBottomBar].
/// If no entries are available, a placeholder message is shown.
class DiaryPreview extends StatefulWidget {
  /// Callback triggered when a diary entry is selected.
  final void Function(String entryId) onViewPage;

  /// Optional callback for the back button in the app bar.
  final VoidCallback? onBack;

  /// Callback to handle bottom navigation interactions.
  final void Function(int)? onBottomTap;

  /// Constructs the [DiaryPreview] screen.
  const DiaryPreview({
    super.key,
    required this.onViewPage,
    required this.onBack,
    this.onBottomTap,
  });

  @override
  State<DiaryPreview> createState() => _DiaryPreviewState();
}

/// State class that handles loading diary entries with pagination,
/// deletion with confirmation, and rendering the UI.
class _DiaryPreviewState extends State<DiaryPreview> {
  List<DiaryCard> _diaryCards = [];
  bool _isLoading = false;
  bool _hasMore = true;

  /// Reference to the last document fetched from Firestore,
  /// used for pagination (cursor-based).
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastFetchedDocument = null;

  @override
  void initState() {
    super.initState();
    _loadMoreCardsFromFirebase();
  }

  /// Loads additional diary entries from Firebase using pagination.
  ///
  /// Fetches a limited number of entries from Firestore,
  /// starting after the last fetched document (if any).
  /// Updates [_diaryCards], [_lastFetchedDocument], and [_hasMore].
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

  /// Builds a 'Load More' button used to trigger pagination manually.
  ///
  /// Appears at the bottom of the list when more entries are available.
  Widget _buildLoadMoreButton() {
    return TextButton(
      onPressed: _loadMoreCardsFromFirebase,
      child: Text(
        'Load More',
        style: GoogleFonts.libreBaskerville(
          fontSize: 18,
          color: const Color(0xFFC97F4F),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom top app bar with title and optional back button
      appBar: ItinereoAppBar(
        title: "Diary",
        textColor: const Color(0xFFF6E1C4),
        pillColor: const Color(0xFFC97F4F),
        topBarColor: const Color(0xFFD28F3F),
        isBackButtonVisible: true,
        onBack: () {
          setState(() {}); // Refresh state
          if (widget.onBack != null) widget.onBack!();
        },
      ),

      backgroundColor: const Color(0xFFF6E1C4),

      // Body: either shows a placeholder if empty or a scrollable list of diary cards
      body:
          _diaryCards.isEmpty && !_isLoading
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No entries found. Start your journey by adding a new entry!',
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 24,
                      color: Color(0xFF4A4A4A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount:
                    _diaryCards.length +
                    (_hasMore ? 1 : 0) + // Reserve space for "Load More" button
                    (_isLoading ? 1 : 0), // Reserve space for loading indicator
                itemBuilder: (context, index) {
                  // Load More button appears at the end of the list if more items are available
                  if (_hasMore && index == _diaryCards.length) {
                    return _buildLoadMoreButton();
                  }

                  // Loading spinner while more entries are being fetched
                  if (_isLoading &&
                      index == _diaryCards.length + (_hasMore ? 1 : 0)) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final diaryCard = _diaryCards[index];

                  // Each diary card is dismissible via swipe to delete
                  return Dismissible(
                    key: Key(diaryCard.id),
                    direction:
                        DismissDirection.endToStart, // Swipe from right to left
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
                    // Confirm before deleting the diary entry
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => ErrorDialog(
                              title: 'Delete Entry',
                              message:
                                  'Are you sure you want to delete this diary entry?',
                              okButtonText: 'Delete',
                              cancelButtonText: 'Cancel',
                              showCancelButton: true,
                            ),
                      );
                    },
                    // Delete from database and update UI if confirmed
                    onDismissed: (direction) async {
                      await DiaryService.instance.deleteEntry(diaryCard.id);
                      setState(() {
                        _diaryCards.removeAt(index);
                      });
                      ItinereoSnackBar.show(
                        context,
                        'Diary entry deleted successfully.',
                      );
                    },
                    // Visual diary card widget
                    child: TravelCard(
                      diaryCard: diaryCard,
                      onViewPage: () => widget.onViewPage(diaryCard.id),
                    ),
                  );
                },
              ),

      // Bottom navigation bar for switching between app sections
      bottomNavigationBar: ItinereoBottomBar(
        currentIndex: 2, // Highlights the Diary tab
        onTap: widget.onBottomTap,
      ),
    );
  }
}
