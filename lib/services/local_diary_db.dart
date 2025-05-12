import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/diary_entry.dart';

class LocalDiaryDatabase {
  static Database? _database;

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
            title TEXT,
            description TEXT,
            date TEXT,
            latitude REAL,
            longitude REAL,
            photoUrls TEXT
          )''');
      },
    );
  }

  Future<void> insertEntry(DiaryEntry entry) async {
    final db = await database;
    await db.insert(
      'diary_entries',
      entry.toJson()..['photoUrls'] = entry.photoUrls.join(','),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiaryEntry>> getEntriesPaginated({
    required int limit,
    required int offset,
  }) async {
    final db = await database;
    final maps = await db.query(
      'diary_entries',
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) {
      return DiaryEntry.fromJson({
        ...map,
        'photoUrls': (map['photoUrls'] as String).split(','),
      });
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
