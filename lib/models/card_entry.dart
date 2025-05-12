/// Represents a summarized version of a diary entry,
/// typically used for preview cards or lists.
///
/// Contains minimal information: ID, date (as a string), place name,
/// and a short description.
class DiaryCard {
  /// Unique identifier of the diary entry.
  final String id;

  /// Date and time when the entry was created or refers to.
  final DateTime date;

  /// A short description or summary of the entry.
  final String description;

  /// Human-readable place name (e.g., city or landmark).
  final String place;

  /// Creates a [DiaryCard] with the given fields.
  DiaryCard({
    required this.id,
    required this.date,
    required this.description,
    required this.place,
  });

  /// Creates a [DiaryCard] from a Firestore document map.
  ///
  /// Parameters:
  /// - [id]: Document ID.
  /// - [map]: Map containing the fields.
  factory DiaryCard.fromMap(String id, Map<String, dynamic> map) {
    return DiaryCard(
      id: id,
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      place: map['place'] ?? '',
    );
  }

  /// Converts this model into a map format for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'place': place,
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
