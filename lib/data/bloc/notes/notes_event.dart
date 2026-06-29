part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class NotesRequested extends NotesEvent {
  const NotesRequested();
}

class NotePinToggled extends NotesEvent {
  const NotePinToggled(this.note);

  final Note note;

  @override
  List<Object?> get props => [note];
}

class NoteDeleted extends NotesEvent {
  const NoteDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class NoteUpserted extends NotesEvent {
  const NoteUpserted(this.note);

  final Note note;

  @override
  List<Object?> get props => [note];
}

class NoteSelectionToggled extends NotesEvent {
  const NoteSelectionToggled(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class SelectAllToggled extends NotesEvent {
  const SelectAllToggled();
}

class SelectionCleared extends NotesEvent {
  const SelectionCleared();
}

class SelectedNotesDeleted extends NotesEvent {
  const SelectedNotesDeleted();
}
