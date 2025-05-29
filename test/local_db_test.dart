import 'package:flutter_test/flutter_test.dart';
import 'package:itinereo/services/geolocator_service.dart';
import 'package:mockito/mockito.dart';
import 'package:itinereo/models/diary_entry.dart';
import 'package:itinereo/services/local_diary_db.dart';
import 'package:sqflite/sqflite.dart';
import 'mocks/mock_definitions.mocks.dart';

class TestableLocalDiaryDatabase extends LocalDiaryDatabase {
  final Database testDb;
  final GeolocatorService testGeo;

  TestableLocalDiaryDatabase(this.testDb, this.testGeo);

  @override
  Future<Database> get database async => testDb;

  @override
  GeolocatorService get _geolocatorService => testGeo;
}

void main() {
  group('LocalDiaryDatabase.insertEntry', () {
    late MockDatabase mockDb;
    late MockGeolocatorService mockGeo;
    late TestableLocalDiaryDatabase db;

    setUp(() {
      mockDb = MockDatabase();
      mockGeo = MockGeolocatorService();
      db = TestableLocalDiaryDatabase(mockDb, mockGeo);
    });

    test('inserts entry with enriched data', () async {
      final entry = DiaryEntry(
        id: 'entry123',
        title: 'Titolo test',
        description: 'descrizione',
        date: DateTime(2023, 1, 1),
        latitude: 10.0,
        longitude: 20.0,
        photoUrls: ['img1', 'img2'],
      );

      when(mockGeo.getCityAndCountryFromPosition(any))
          .thenAnswer((_) async => 'Roma, Italia');

      when(mockDb.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      await db.insertEntry(entry, 'user123');

      verify(mockDb.insert(
        'diary_entries',
        argThat(allOf(
          containsPair('id', 'entry123'),
          containsPair('userId', 'user123'),
          containsPair('location', 'Beled-es-Sudan, Chad'),
          containsPair('photoUrls', 'img1,img2'),
        )),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });
  });
}
