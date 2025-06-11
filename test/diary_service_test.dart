import 'package:flutter_test/flutter_test.dart';
import 'package:itinereo/models/diary_card.dart';
import 'package:mockito/mockito.dart';
import 'package:itinereo/models/diary_entry.dart';
import 'package:itinereo/services/diary_service.dart';
import 'mocks/mock_definitions.mocks.dart';

void main() {
  group('DiaryService', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocRef;
    late MockLocalDiaryDatabase mockLocalDb;
    late MockGeolocatorService mockGeo;

    late DiaryService diaryService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      mockLocalDb = MockLocalDiaryDatabase();
      mockGeo = MockGeolocatorService();

      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('testUser');

      when(mockFirestore.collection('Users')).thenReturn(mockCollection);
      when(mockCollection.doc('testUser')).thenReturn(mockDocRef);
      when(mockDocRef.collection('diary_entries')).thenReturn(mockCollection);

      diaryService = DiaryService.test(
        firestore: mockFirestore,
        auth: mockAuth,
        localDb: mockLocalDb,
        geoService: mockGeo,
      );
    });

    test('addEntry calls Firestore set with correct data', () async {
      final entry = DiaryEntry(
        id: 'entry123',
        title: 'Test Entry',
        description: 'Descrizione',
        date: DateTime(2023, 1, 1),
        latitude: 10.0,
        longitude: 20.0,
        location: 'Roma',
        photoUrls: ['url1'],
      );

      when(mockCollection.doc('entry123')).thenReturn(mockDocRef);
      when(mockDocRef.set(entry.toMap())).thenAnswer((_) async => null);

      await diaryService.addEntry(entry);

      verify(mockDocRef.set(entry.toMap())).called(1);
    });

    test('getDiaryCards returns DiaryCard from Firestore', () async {
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      final fakeData = {
        'title': 'Viaggio',
        'date': DateTime(2023, 1, 1).toIso8601String(),
        'latitude': 10.0,
        'longitude': 20.0,
        'photoUrls': ['img1.jpg'],
        'location': 'Beled-es-Sudan, Chad',
      };

      when(
        mockCollection.orderBy('date', descending: true),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.docs).thenReturn([mockDoc]);
      when(mockDoc.data()).thenReturn(fakeData);
      when(mockDoc.id).thenReturn('entry123');

      when(
        mockGeo.getCityAndCountryFromPosition(any),
      ).thenAnswer((_) async => 'Roma, Italia');

      final cards = await diaryService.getDiaryCards();

      expect(cards, isNotEmpty);
      expect(cards.first.id, 'entry123');
      expect(cards.first.place, 'Beled-es-Sudan, Chad');
    });

    test('getDiaryCards falls back to local DB on error', () async {
      when(
        mockCollection.orderBy('date', descending: true),
      ).thenThrow(Exception('Firestore error'));

      when(
        mockLocalDb.getDiaryCardsFromLocalDb(
          userId: anyNamed('userId'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        ),
      ).thenAnswer(
        (_) async => [
          DiaryCard(
            id: 'offline1',
            title: 'Offline',
            date: DateTime(2023, 1, 1),
            place: 'Offline',
            imageUrl: '',
          ),
        ],
      );

      final result = await diaryService.getDiaryCards();

      expect(result, isNotEmpty);
      expect(result.first.id, 'offline1');
    });
    test('deleteEntry calls Firestore and local DB', () async {
      when(mockCollection.doc('entry123')).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenAnswer((_) async => null);

      when(mockLocalDb.deleteEntry('entry123')).thenAnswer((_) async => null);

      await diaryService.deleteEntry('entry123');

      verify(mockDocRef.delete()).called(1);
      verify(mockLocalDb.deleteEntry('entry123')).called(1);
    });
  });
}
