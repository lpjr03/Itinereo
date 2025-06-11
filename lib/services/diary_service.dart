import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/models/diary_entry.dart';
import 'package:itinereo/services/geolocator_service.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service responsible for managing diary entries in Firestore and local SQLite.
///
/// This class handles:
/// - Adding and deleting entries in Firestore.
/// - Fetching diary cards and entries.
/// - Falling back to local SQLite when Firestore is unavailable.
/// - Syncing local cache with remote data.
/// - Handling storage permissions.
///
/// Use `DiaryService.instance` to access the singleton.
class DiaryService {
  static final DiaryService instance = DiaryService._internal();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocalDiaryDatabase _localDb;
  final GeolocatorService _geolocatorService;

  /// Factory constructor to access the singleton instance.
  factory DiaryService() => instance;

  /// Internal constructor used to initialize the singleton instance.
  DiaryService._internal()
    : _firestore = FirebaseFirestore.instance,
      _auth = FirebaseAuth.instance,
      _localDb = LocalDiaryDatabase(),
      _geolocatorService = GeolocatorService();

  /// Constructor used for unit testing with injected dependencies.
  DiaryService.test({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required LocalDiaryDatabase localDb,
    required GeolocatorService geoService,
  }) : _firestore = firestore,
       _auth = auth,
       _localDb = localDb,
       _geolocatorService = geoService;

  /// Returns the current user's UID.
  String get _userId => _auth.currentUser!.uid;

  /// Returns the reference to the user's diary entries collection in Firestore.
  CollectionReference<Map<String, dynamic>> get _entryCollection =>
      _firestore.collection('Users').doc(_userId).collection('diary_entries');

  /// Adds a diary entry to Firestore under the current user's collection.
  Future<void> addEntry(DiaryEntry entry) async {
    await _entryCollection.doc(entry.id).set(entry.toMap());
  }

  /// Retrieves a paginated list of diary cards from Firestore.
  ///
  /// If an error occurs (e.g., offline), it fetches entries from local storage.
  Future<List<DiaryCard>> getDiaryCards({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final snapshot =
          await _entryCollection
              .orderBy('date', descending: true)
              .limit(limit + offset)
              .get();

      final docs = snapshot.docs.skip(offset).take(limit);
      List<DiaryCard> cards = [];

      for (var doc in docs) {
        final data = doc.data();
        final id = doc.id;
        final date = DateTime.parse(data['date']);
        final title = data['title'];
        final photoUrls = List<String>.from(data['photoUrls'] ?? []);
        final place = data['location'] ?? '';

        cards.add(
          DiaryCard(
            id: id,
            date: date,
            place: place,
            title: title,
            imageUrl: photoUrls.isNotEmpty ? photoUrls.first : '',
          ),
        );
      }

      return cards;
    } catch (e) {
      return _localDb.getDiaryCardsFromLocalDb(
        userId: _userId,
        limit: limit,
        offset: offset,
      );
    }
  }

  /// Returns a full diary entry by ID, from Firestore or local DB if offline.
  Future<DiaryEntry?> getEntryById(String entryId) async {
    try {
      final doc = await _entryCollection.doc(entryId).get();
      if (doc.exists) {
        return DiaryEntry.fromMap(doc.id, doc.data()!);
      }
    } catch (e) {
      return await _localDb.getEntryById(entryId);
    }
    return null;
  }

  /// Deletes a diary entry from both Firestore and local storage.
  Future<void> deleteEntry(String entryId) async {
    await _entryCollection.doc(entryId).delete();
    await _localDb.deleteEntry(entryId);
  }

  /// Syncs the latest 10 remote entries to local storage on first login.
  ///
  /// This is useful when the local DB is empty (e.g., after a fresh install).
  Future<void> syncLocalEntriesWithFirestore(
    UserCredential userCredential,
  ) async {
    final userId = userCredential.user!.uid;

    final localEntries = await LocalDiaryDatabase().getAllEntries(
      userId: userId,
    );
    if (localEntries.isEmpty) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(userId)
              .collection("diary_entries")
              .orderBy("date", descending: true)
              .limit(10)
              .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final entry = DiaryEntry.fromMap(doc.id, data);

        await _localDb.insertEntry(entry, userId, data['location'] ?? '');
      }
    }
  }

  /// Requests storage permission required for accessing photos.
  ///
  /// Returns `true` if the permission is granted, otherwise `false`.
  Future<bool> requestStoragePermission() async {
    if (await Permission.photos.isDenied || await Permission.storage.isDenied) {
      final status = await [Permission.photos, Permission.storage].request();

      if (status[Permission.photos]?.isDenied == true ||
          status[Permission.storage]?.isDenied == true) {
        return false;
      }
    }
    return true;
  }

  /// Loads more diary entries in paginated form from Firestore.
  ///
  /// Starts after the last fetched document.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchMoreDiaryEntries({
    QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument,
    required int limit,
  }) async {
    Query<Map<String, dynamic>> query = _entryCollection
        .orderBy('date', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }
}
