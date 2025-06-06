/// Represents a summarized version of a diary entry,
/// typically used for preview cards or lists.
///
/// Contains minimal information: ID, date, place name,
/// a short description, and a representative image URL.
class DiaryCard {
  /// Unique identifier of the diary entry.
  final String id;

  /// Date and time when the entry was created or refers to.
  final DateTime date;

  /// A short description or summary of the entry.
  final String title;

  /// Human-readable place name (e.g., city or landmark).
  final String place;

  /// URL of a representative photo associated with the entry.
  final String imageUrl;

  /// Creates a [DiaryCard] with the given fields.
  DiaryCard({
    required this.id,
    required this.date,
    required this.title,
    required this.place,
    required this.imageUrl,
  });

  /// Creates a [DiaryCard] from a Firestore document map.
  ///
  /// Parameters:
  /// - [id]: Document ID.
  /// - [map]: Map containing the fields.
  factory DiaryCard.fromMap(String id, Map<String, dynamic> map) {
  final photoUrls = List<String>.from(map['photoUrls'] ?? []);
  final imageUrl = photoUrls.isNotEmpty ? photoUrls.first : '';

  return DiaryCard(
    id: id,
    title: map['title'] ?? '',
    date: DateTime.parse(map['date']),
    place: map['location'] ?? '',
    imageUrl: imageUrl,
  );
}


  /// Converts this model into a map format for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'description': title,
      'place': place,
      'imageUrl': imageUrl,
    };
  }

  /// Converts this model into a JSON map, including the ID.
  Map<String, dynamic> toJson() => {
        'id': id,
        ...toMap(),
      };

  /// Creates a [DiaryCard] from a JSON map.
  factory DiaryCard.fromJson(Map<String, dynamic> json) {
    return DiaryCard.fromMap(json['id'], json);
  }
}
