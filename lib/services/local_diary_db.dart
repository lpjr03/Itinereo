import 'package:geolocator/geolocator.dart';
import 'package:itinereo/models/card_entry.dart';
import 'package:itinereo/services/geolocator_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/diary_entry.dart';

class LocalDiaryDatabase {
  static Database? _database;
  final GeolocatorService _geolocatorService = GeolocatorService();
  final int maxEntries;

  LocalDiaryDatabase({this.maxEntries = 10});

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''CREATE TABLE diary_entries (
            id TEXT PRIMARY KEY,
            userId TEXT, 
            title TEXT,
            description TEXT,
            date TEXT,
            latitude REAL,
            longitude REAL,
            location TEXT,
            photoUrls TEXT
          )''');
      },
    );
  }

  Future<void> insertEntry(
    DiaryEntry entry,
    String userId,
    String optionalLocation,
  ) async {
    final db = await database;

    final position = Position(
      latitude: entry.latitude,
      longitude: entry.longitude,
      timestamp: entry.date,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
      speedAccuracy: 0,
    );

    String location;
    if (optionalLocation.isNotEmpty) {
      location = optionalLocation;
    } else {
      try {
        location = await _geolocatorService.getCityAndCountryFromPosition(
          position,
        );
      } catch (e) {
        location = 'Sconosciuta';
      }
    }

    final entryMap =
        entry.toJson()
          ..['userId'] = userId
          ..['photoUrls'] = entry.photoUrls.join(',')
          ..['location'] = location;

    await db.insert(
      'diary_entries',
      entryMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM diary_entries WHERE userId = ?',
      [userId],
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;

    if (count > maxEntries) {
      final excess = count - maxEntries;

      await db.delete(
        'diary_entries',
        where:
            'id IN (SELECT id FROM diary_entries WHERE userId = ? ORDER BY date ASC LIMIT ?)',
        whereArgs: [userId, excess],
      );
    }
  }

  Future<List<DiaryEntry>> getAllEntries({required String userId}) async {
    final db = await database;

    final maps = await db.query(
      'diary_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return maps.map((map) {
      final raw = map['photoUrls'] as String?;
      final list =
          (raw == null || raw.trim().isEmpty)
              ? <String>[]
              : raw.split(',').where((e) => e.trim().isNotEmpty).toList();

      return DiaryEntry.fromJson({...map, 'photoUrls': list});
    }).toList();
  }

  Future<List<DiaryCard>> getDiaryCardsFromLocalDb({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    final db = await database;

    final maps = await db.query(
      'diary_entries',
      columns: ['id', 'title', 'date', 'location', 'photoUrls'],
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) {
      final photoUrls =
          (map['photoUrls'] as String?)
              ?.split(',')
              .where((url) => url.trim().isNotEmpty)
              .toList() ??
          [];

      return DiaryCard(
        id: map['id'] as String,
        title: map['title'] as String,
        date: DateTime.parse(map['date'] as String),
        place: map['location'] as String? ?? '',
        imageUrl: photoUrls.isNotEmpty ? photoUrls.first : '',
      );
    }).toList();
  }

  Future<DiaryEntry?> getEntryById(String id) async {
    final db = await database;

    final result = await db.query(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return DiaryEntry.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }
}
