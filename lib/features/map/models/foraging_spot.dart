class ForagingSpot {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String? mushroomId;
  final String? mushroomName;
  final String notes;
  final DateTime foundAt;
  final String? photoPath;

  const ForagingSpot({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.mushroomId,
    this.mushroomName,
    required this.notes,
    required this.foundAt,
    this.photoPath,
  });

  ForagingSpot copyWith({
    String? id,
    String? title,
    double? latitude,
    double? longitude,
    String? mushroomId,
    String? mushroomName,
    String? notes,
    DateTime? foundAt,
    String? photoPath,
    bool clearPhoto = false,
  }) {
    return ForagingSpot(
      id: id ?? this.id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mushroomId: mushroomId ?? this.mushroomId,
      mushroomName: mushroomName ?? this.mushroomName,
      notes: notes ?? this.notes,
      foundAt: foundAt ?? this.foundAt,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'mushroomId': mushroomId,
      'mushroomName': mushroomName,
      'notes': notes,
      'foundAt': foundAt.toIso8601String(),
      'photoPath': photoPath,
    };
  }

  factory ForagingSpot.fromMap(Map<String, dynamic> map) {
    return ForagingSpot(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Setal sin nombre',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      mushroomId: map['mushroomId'] as String?,
      mushroomName: map['mushroomName'] as String?,
      notes: map['notes'] as String? ?? '',
      foundAt: DateTime.tryParse(map['foundAt'] as String? ?? '') ??
          DateTime.now(),
      photoPath: map['photoPath'] as String?,
    );
  }
}
