class AiChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime createdAt;
  final String? imagePath;
  final List<String> matchedMushroomIds;
  final bool isPendingSync;

  const AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.createdAt,
    this.imagePath,
    this.matchedMushroomIds = const <String>[],
    this.isPendingSync = false,
  });

  AiChatMessage copyWith({
    String? id,
    bool? isUser,
    String? text,
    DateTime? createdAt,
    String? imagePath,
    List<String>? matchedMushroomIds,
    bool? isPendingSync,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      matchedMushroomIds: matchedMushroomIds ?? this.matchedMushroomIds,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUser': isUser,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'matchedMushroomIds': matchedMushroomIds,
      'isPendingSync': isPendingSync,
    };
  }

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: json['isUser'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      imagePath: json['imagePath'] as String?,
      matchedMushroomIds:
          (json['matchedMushroomIds'] as List<dynamic>? ?? const <dynamic>[])
              .map((e) => e.toString())
              .toList(),
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );
  }
}
