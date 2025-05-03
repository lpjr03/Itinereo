import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/diary_entry.dart';

class DiaryService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _entryCollection =>
      _firestore.collection('Users').doc(_userId).collection('diary_entries');

  Future<void> addEntry(DiaryEntry entry) async {
    await _entryCollection.doc(entry.id).set(entry.toMap());
  }

  Future<List<DiaryEntry>> getEntries() async {
    final snapshot = await _entryCollection.get();

    return snapshot.docs
        .map((doc) => DiaryEntry.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<DiaryEntry?> getEntryById(String entryId) async {
    final doc = await _entryCollection.doc(entryId).get();

    if (doc.exists) {
      return DiaryEntry.fromMap(doc.id, doc.data()!);
    } else {
      return null;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    await _entryCollection.doc(entryId).delete();
  }
}
