import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/models/diary_entry.dart';
import 'package:itinereo/services/geolocator_service.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:permission_handler/permission_handler.dart';

class DiaryService {
  static final DiaryService instance = DiaryService._internal();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocalDiaryDatabase _localDb;
  final GeolocatorService _geolocatorService;
  factory DiaryService() => instance;

  DiaryService._internal()
    : _firestore = FirebaseFirestore.instance,
      _auth = FirebaseAuth.instance,
      _localDb = LocalDiaryDatabase(),
      _geolocatorService = GeolocatorService();

  DiaryService.test({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required LocalDiaryDatabase localDb,
    required GeolocatorService geoService,
  }) : _firestore = firestore,
       _auth = auth,
       _localDb = localDb,
       _geolocatorService = geoService;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _entryCollection =>
      _firestore.collection('Users').doc(_userId).collection('diary_entries');

  Future<void> addEntry(DiaryEntry entry) async {
    await _entryCollection.doc(entry.id).set(entry.toMap());
  }

  Future<List<DiaryCard>> getDiaryCards(
    String apiKey, {
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
        final latitude = (data['latitude'] as num).toDouble();
        final longitude = (data['longitude'] as num).toDouble();
        final photoUrls = List<String>.from(data['photoUrls'] ?? []);
        Position position = Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: date,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
          speedAccuracy: 0,
        );

        final place = await _geolocatorService.getCityAndCountryFromPosition(
          position,
        );

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

  Future<void> deleteEntry(String entryId) async {
    await _entryCollection.doc(entryId).delete();
    await _localDb.deleteEntry(entryId);
  }

  Future<void> syncLocalEntriesWithFirestore(
    UserCredential userCredential,
  ) async {
    final userId = userCredential.user!.uid;

    final localEntries = await LocalDiaryDatabase().getRecentDiaryEntries(
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

        await LocalDiaryDatabase().insertEntry(
          entry,
          userId,
          data['location'] ?? '',
        );
      }
    }
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.photos.isDenied || await Permission.storage.isDenied) {
      final status = await [Permission.photos, Permission.storage].request();

      if (status[Permission.photos]?.isDenied == true ||
          status[Permission.storage]?.isDenied == true) {
        throw Exception('Storage permission not granted');
      }
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchMoreDiaryEntries({
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

Future<List<DiaryCard>> getDiaryCardsPaginated({
  required int limit,
  QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument,
}) async {
  try {
    Query<Map<String, dynamic>> query = _entryCollection
        .orderBy('date', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    List<DiaryCard> cards = [];

    for (final doc in docs) {
      final data = doc.data();
      final id = doc.id;
      final date = DateTime.parse(data['date']);
      final title = data['title'];
      final latitude = (data['latitude'] as num).toDouble();
      final longitude = (data['longitude'] as num).toDouble();
      final photoUrls = List<String>.from(data['photoUrls'] ?? []);

      final place = await _geolocatorService.getCityAndCountryFromPosition(
        Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: date,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
          speedAccuracy: 0,
        ),
      );

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
    // fallback solo se la fetch Firebase fallisce (es. offline)
    return _localDb.getDiaryCardsFromLocalDb(
      userId: _userId,
      limit: limit,
      offset: 0, // non c'è scroll in fallback
    );
  }
}




}
