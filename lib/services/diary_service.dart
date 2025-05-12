import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/models/diary_entry.dart';
import 'package:itinereo/services/local_diary_db.dart';

class DiaryService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _localDb = LocalDiaryDatabase();

  String get _userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _entryCollection =>
      _firestore.collection('Users').doc(_userId).collection('diary_entries');

  Future<void> addEntry(DiaryEntry entry) async {
    await _entryCollection.doc(entry.id).set(entry.toMap());
    await _localDb.insertEntry(entry);
  }

  Future<String> getCityFromCoordinates(
    double lat,
    double lng,
    String apiKey,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'] != null && data['results'].isNotEmpty) {
        String? city;
        String? country;

        for (var component in data['results'][0]['address_components']) {
          final types = List<String>.from(component['types']);

          if (types.contains('locality')) city = component['long_name'];
          if (types.contains('country')) country = component['long_name'];
        }

        if (city != null && country != null) return '$city, $country';
        if (country != null) return country;
      }

      return 'Unknown location';
    } else {
      throw Exception('Failed to fetch location: ${response.statusCode}');
    }
  }

Future<List<DiaryCard>> getDiaryCards(String apiKey, {int limit = 10, int offset = 0}) async {
  try {
    final snapshot = await _entryCollection
        .orderBy('date', descending: true)
        .limit(limit + offset)
        .get();

    final docs = snapshot.docs.skip(offset).take(limit);

    List<DiaryCard> cards = [];

    for (var doc in docs) {
      final data = doc.data();
      final id = doc.id;
      final date = DateTime.parse(data['date']);
      final description = data['description'] ?? '';
      final latitude = (data['latitude'] as num).toDouble();
      final longitude = (data['longitude'] as num).toDouble();

      final city = await getCityFromCoordinates(latitude, longitude, apiKey);

      cards.add(
        DiaryCard(
          id: id,
          date: date,
          place: city,
          description: description,
        ),
      );
    }

    return cards;
  } catch (e) {
    final localEntries = await _localDb.getEntriesPaginated(limit: limit, offset: offset);
    return localEntries
        .map(
          (entry) => DiaryCard(
            id: entry.id,
            date: entry.date,
            place: 'Local data',
            description: entry.description,
          ),
        )
        .toList();
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
}
