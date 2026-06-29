import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:notes/core/models/note.dart';

part 'editor_state.dart';

class EditorCubit extends Cubit<EditorState> {
  EditorCubit({Note? note})
      : super(note == null ? const EditorState() : _from(note));

  static EditorState _from(Note note) => EditorState(
        id: note.id,
        title: note.title,
        body: note.body,
        isPinned: note.isPinned,
        updatedAt: note.updatedAt,
      );

  void titleChanged(String value) => emit(state.copyWith(title: value));

  void bodyChanged(String value) => emit(state.copyWith(body: value));

  void togglePin() => emit(state.copyWith(isPinned: !state.isPinned));

  Future<Note?> save({required String untitledLabel}) async {
    if (!state.hasContent) return null;

    emit(state.copyWith(isSaving: true));
    await Future.delayed(const Duration(milliseconds: 700));

    final now = DateTime.now();
    final title = state.title.trim();
    final note = Note(
      id: state.id,
      title: title.isEmpty ? untitledLabel : title,
      body: state.body,
      updatedAt: now,
      isPinned: state.isPinned,
    );

    emit(state.copyWith(isSaving: false, updatedAt: now));
    return note;
  }
}
