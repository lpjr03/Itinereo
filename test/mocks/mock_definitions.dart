import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itinereo/services/local_storage_service.dart';
import 'package:itinereo/services/location_service.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
  LocalDiaryDatabase,
  GeolocatorService,
  Query<Map<String, dynamic>>,
  QuerySnapshot<Map<String, dynamic>>,
  QueryDocumentSnapshot<Map<String, dynamic>>,
  Database,
])
void main() {}
