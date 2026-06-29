import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/core/models/note.dart';
import 'package:notes/data/notes/notes_repository.dart';


part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._repo) : super(const NotesState()) {
    on<NotesRequested>(_onRequested);
    on<NotePinToggled>(_onPinToggled);
    on<NoteDeleted>(_onDeleted);
    on<NoteUpserted>(_onUpserted);
    on<NoteSelectionToggled>(_onSelectionToggled);
    on<SelectAllToggled>(_onSelectAllToggled);
    on<SelectionCleared>(_onSelectionCleared);
    on<SelectedNotesDeleted>(_onSelectedDeleted);
  }

  final NotesRepository _repo;

  Future<void> _onRequested(
      NotesRequested event, Emitter<NotesState> emit) async {
    emit(state.copyWith(status: NotesStatus.loading));
    try {
      final notes = await _repo.fetchNotes();
      emit(state.copyWith(status: NotesStatus.success, notes: notes));
    } catch (e) {
      emit(state.copyWith(status: NotesStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> _onPinToggled(
      NotePinToggled event, Emitter<NotesState> emit) async {
    await _repo.upsert(event.note.copyWith(isPinned: !event.note.isPinned));
    await _refresh(emit);
  }

  Future<void> _onDeleted(NoteDeleted event, Emitter<NotesState> emit) async {
    await _repo.delete(event.id);
    await _refresh(emit);
  }

  Future<void> _onUpserted(NoteUpserted event, Emitter<NotesState> emit) async {
    await _repo.upsert(event.note);
    await _refresh(emit);
  }

  void _onSelectionToggled(
      NoteSelectionToggled event, Emitter<NotesState> emit) {
    final selected = Set<int>.of(state.selectedIds);
    if (!selected.add(event.id)) selected.remove(event.id);
    emit(state.copyWith(selectedIds: selected));
  }

  void _onSelectAllToggled(SelectAllToggled event, Emitter<NotesState> emit) {
    final selected = state.allSelected
        ? <int>{}
        : state.notes.map((n) => n.id).whereType<int>().toSet();
    emit(state.copyWith(selectedIds: selected));
  }

  void _onSelectionCleared(SelectionCleared event, Emitter<NotesState> emit) {
    emit(state.copyWith(selectedIds: {}));
  }

  Future<void> _onSelectedDeleted(
      SelectedNotesDeleted event, Emitter<NotesState> emit) async {
    await _repo.deleteMany(state.selectedIds.toList());
    final notes = await _repo.fetchNotes();
    emit(state
        .copyWith(status: NotesStatus.success, notes: notes, selectedIds: {}));
  }

  Future<void> _refresh(Emitter<NotesState> emit) async {
    final notes = await _repo.fetchNotes();
    emit(state.copyWith(status: NotesStatus.success, notes: notes));
  }
}
