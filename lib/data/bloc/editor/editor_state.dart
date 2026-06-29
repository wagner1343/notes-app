part of 'editor_cubit.dart';

class EditorState extends Equatable {
  const EditorState({
    this.id,
    this.title = '',
    this.body = '',
    this.isPinned = false,
    this.isSaving = false,
    this.updatedAt,
  });

  final int? id;
  final String title;
  final String body;
  final bool isPinned;
  final bool isSaving;
  final DateTime? updatedAt;

  bool get isNew => id == null;

  int get charCount => body.length;

  bool get hasContent => title.trim().isNotEmpty || body.trim().isNotEmpty;

  EditorState copyWith({
    int? id,
    String? title,
    String? body,
    bool? isPinned,
    bool? isSaving,
    DateTime? updatedAt,
  }) {
    return EditorState(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isPinned: isPinned ?? this.isPinned,
      isSaving: isSaving ?? this.isSaving,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, body, isPinned, isSaving, updatedAt];
}
