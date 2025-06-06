/// Represents a single personal diary entry.
///
/// Each entry includes a title, description, date, geographic position,
/// a human-readable location name, and a list of associated photo URLs stored in Firebase Storage.
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

  /// Human-readable name of the location (e.g., city or place name).
  final String location;

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
    required this.location,
    required this.photoUrls,
  });

  /// Converts the entry to a map format, useful for saving into Firestore.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'photoUrls': photoUrls,
    };
  }

  /// Creates a [DiaryEntry] instance from a given map and document ID.
  factory DiaryEntry.fromMap(String id, Map<String, dynamic> map) {
    return DiaryEntry(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      location: map['location'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
    );
  }

  /// Converts the entry to a JSON-compatible map, including the document ID.
  Map<String, dynamic> toJson() => {
        'id': id,
        ...toMap(),
      };

  /// Creates a [DiaryEntry] from a JSON map.
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry.fromMap(json['id'], json);
  }
}
