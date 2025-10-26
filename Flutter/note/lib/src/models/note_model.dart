class NoteModel {
  final String id;
  final String title;
  final String preview;
  final DateTime createdAt;
  final bool pinned;
  final DateTime? pinnedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.preview,
    required this.createdAt,
    this.pinned = false,
    this.pinnedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? preview,
    DateTime? createdAt,
    bool? pinned,
    DateTime? pinnedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      createdAt: createdAt ?? this.createdAt,
      pinned: pinned ?? this.pinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
    );
  }
}
