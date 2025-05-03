/// Rappresenta una singola voce del diario personale.
///
/// Ogni entry contiene un titolo, una descrizione, la data,
/// la posizione geografica e una lista di URL di foto associate.
class DiaryEntry {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final double latitude;
  final double longitude;
  final List<String> photoUrls;

  /// Crea una nuova istanza di [DiaryEntry].
  DiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.photoUrls,
  });

  /// Converte l'entry in una mappa per salvarla su Firestore.
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

  /// Crea un'istanza di [DiaryEntry] a partire da una mappa e un ID.
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

  /// Converte l'entry in una mappa JSON, includendo anche l'ID.
  Map<String, dynamic> toJson() => {
        'id': id,
        ...toMap(),
      };

  /// Crea un'istanza di [DiaryEntry] da un oggetto JSON.
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry.fromMap(json['id'], json);
  }
}
