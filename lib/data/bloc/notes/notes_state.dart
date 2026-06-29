part of 'notes_bloc.dart';

enum NotesStatus { loading, success, failure }

class NotesState extends Equatable {
  const NotesState({
    this.status = NotesStatus.loading,
    this.notes = const [],
    this.errorMessage,
    this.selectedIds = const {},
  });

  final NotesStatus status;
  final List<Note> notes;
  final String? errorMessage;
  final Set<int> selectedIds;

  List<Note> get pinned => notes.where((n) => n.isPinned).toList();

  List<Note> get others => notes.where((n) => !n.isPinned).toList();

  bool get isEmpty => status == NotesStatus.success && notes.isEmpty;

  bool get isSelecting => selectedIds.isNotEmpty;

  bool get allSelected =>
      notes.isNotEmpty && selectedIds.length == notes.length;

  bool isSelected(int? id) => id != null && selectedIds.contains(id);

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? errorMessage,
    Set<int>? selectedIds,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage, selectedIds];
}
