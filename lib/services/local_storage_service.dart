import 'package:geolocator/geolocator.dart';
import 'package:itinereo/models/diary_card.dart';
import 'package:itinereo/services/location_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/diary_entry.dart';

/// A local SQLite-backed database for storing [DiaryEntry] and [DiaryCard] data.
///
/// This database supports:
/// - Offline persistence of diary entries.
/// - Automatic cleanup of oldest entries beyond a configurable [maxEntries].
/// - Conversion from Firestore-like models to local-friendly formats.
/// - Lazy location resolution via [GeolocatorService].
class LocalDiaryDatabase {
  static Database? _database;
  final GeolocatorService _geolocatorService = GeolocatorService();

  /// Maximum number of entries to store per user.
  final int maxEntries;

  /// Creates a [LocalDiaryDatabase] instance.
  ///
  /// Defaults to keeping at most [maxEntries] entries per user.
  LocalDiaryDatabase({this.maxEntries = 10});

  /// Returns the active [Database] instance, initializing it if needed.
  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  /// Initializes the SQLite database and creates the `diary_entries` table.
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE diary_entries (
            id TEXT PRIMARY KEY,
            userId TEXT, 
            title TEXT,
            description TEXT,
            date TEXT,
            latitude REAL,
            longitude REAL,
            location TEXT,
            photoUrls TEXT
          )
        ''');
      },
    );
  }

  /// Inserts a [DiaryEntry] into the local database for a specific user.
  ///
  /// If [optionalLocation] is provided, it overrides the reverse geolocation lookup.
  /// Otherwise, a location is derived using [_geolocatorService].
  /// Automatically removes the oldest entries if the user exceeds [maxEntries].
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
        where: '''
          id IN (
            SELECT id FROM diary_entries
            WHERE userId = ?
            ORDER BY date ASC
            LIMIT ?
          )
        ''',
        whereArgs: [userId, excess],
      );
    }
  }

  /// Retrieves all [DiaryEntry]s for a given user, ordered by most recent date.
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

  /// Retrieves a paginated list of [DiaryCard]s for preview display.
  ///
  /// Each card includes id, title, date, location, and the first image (if any).
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

  /// Returns a specific [DiaryEntry] by its [id], or null if not found.
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

  /// Deletes a diary entry by its [id].
  Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }
}
