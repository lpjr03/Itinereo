/// Represents a single personal diary entry.
///
/// Each entry includes a title, description, date, geographic position,
/// and a list of associated photo URLs stored in Firebase Storage.
///
/// Example:
/// ```dart
/// final entry = DiaryEntry(
///   id: '1',
///   title: 'Trip to the mountains',
///   description: 'It was a wonderful day with lots of hiking.',
///   date: DateTime.now(),
///   latitude: 45.123,
///   longitude: 9.456,
///   photoUrls: ['https://.../photo1.jpg'],
/// );
/// ```
class DiaryEntry {
  /// Unique identifier for the diary entry.
  final String id;

  /// Title of the diary entry.
  final String title;

  /// Detailed description or content of the diary entry.
  final String description;

  /// Date and time when the entry was created or refers to.
  final DateTime date;

  /// Latitude coordinate of the entry location.
  final double latitude;

  /// Longitude coordinate of the entry location.
  final double longitude;

  /// List of photo URLs associated with the entry.
  final List<String> photoUrls;

  /// Creates a new instance of [DiaryEntry].
  ///
  /// All fields are required and should be properly initialized.
  DiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.photoUrls,
  });

  /// Converts the entry to a map format, useful for saving into Firestore.
  ///
  /// Returns:
  /// - A `Map<String, dynamic>` containing the title, description, date (ISO8601 format),
  /// latitude, longitude, and photo URLs.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'photoUrls': photoUrls,
    };
  }

  /// Creates a [DiaryEntry] instance from a given map and document ID.
  ///
  /// Parameters:
  /// - [id]: The document ID.
  /// - [map]: A map containing the entry fields.
  ///
  /// Returns:
  /// - A [DiaryEntry] object constructed from the provided data.
  factory DiaryEntry.fromMap(String id, Map<String, dynamic> map) {
    return DiaryEntry(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
    );
  }

  /// Converts the entry to a JSON-compatible map, including the document ID.
  ///
  /// Returns:
  /// - A `Map<String, dynamic>` with all entry fields plus the ID.
  Map<String, dynamic> toJson() => {
        'id': id,
        ...toMap(),
      };

  /// Creates a [DiaryEntry] from a JSON map.
  ///
  /// Parameters:
  /// - [json]: A JSON map fetched from Firestore.
  ///
  /// Returns:
  /// - A [DiaryEntry] object.
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry.fromMap(json['id'], json);
  }
}
