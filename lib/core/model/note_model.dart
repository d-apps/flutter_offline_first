class NoteModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool synced;

  NoteModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      synced: json['synced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'synced': synced,
    };
  }

  NoteModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
}