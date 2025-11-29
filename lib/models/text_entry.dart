class TextEntry {
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  TextEntry({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert TextEntry to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create TextEntry from Firebase JSON
  factory TextEntry.fromJson(Map<dynamic, dynamic> json, String key) {
    return TextEntry(
      id: key,
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // Create a copy of TextEntry with updated fields
  TextEntry copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TextEntry(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
