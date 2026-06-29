import 'package:equatable/equatable.dart';

class Note extends Equatable {
  const Note({
    this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.isPinned = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool isPinned;

  int get charCount => body.length;

  String get snippet => body.replaceAll('\n', ' ').trim();

  Note copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int? ?? 0,
      ),
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, body, updatedAt, isPinned];
}
