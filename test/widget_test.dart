import 'package:flutter_test/flutter_test.dart';
import 'package:notes/core/models/note.dart';
import 'package:notes/data/bloc/notes/notes_bloc.dart';
import 'package:notes/data/bloc/search/search_cubit.dart';
import 'package:notes/data/notes/notes_repository.dart';
import 'package:notes/data/search/search_repository.dart';

// In-memory repo so we can exercise the bloc without sqflite.
class FakeNotesRepository implements NotesRepository {
  FakeNotesRepository([List<Note>? seed]) : _notes = [...?seed];

  final List<Note> _notes;
  int _nextId = 100;

  @override
  Future<List<Note>> fetchNotes() async {
    final sorted = [..._notes]..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return sorted;
  }

  @override
  Future<Note> upsert(Note note) async {
    if (note.id == null) {
      final saved = note.copyWith(id: _nextId++);
      _notes.add(saved);
      return saved;
    }
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i != -1) _notes[i] = note;
    return note;
  }

  @override
  Future<void> delete(int id) async => _notes.removeWhere((n) => n.id == id);

  @override
  Future<void> deleteMany(List<int> ids) async =>
      _notes.removeWhere((n) => ids.contains(n.id));
}

// In-memory recent searches, mirroring the dedupe + recency ordering of the
// real (sqflite-backed) repository.
class FakeSearchRepository implements SearchRepository {
  final List<String> _terms = [];

  @override
  Future<List<String>> recentSearches() async => List.unmodifiable(_terms);

  @override
  Future<void> record(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _terms.removeWhere((t) => t.toLowerCase() == q.toLowerCase());
    _terms.insert(0, q);
  }

  @override
  Future<void> remove(String query) async {
    _terms.removeWhere((t) => t.toLowerCase() == query.toLowerCase());
  }
}

Note buildNote(int id, String title, {bool pinned = false}) {
  return Note(
    id: id,
    title: title,
    body: '$title body',
    updatedAt: DateTime(2026, 1, id),
    isPinned: pinned,
  );
}

void main() {
  group('NotesBloc', () {
    test('loads notes', () async {
      final bloc = NotesBloc(FakeNotesRepository([buildNote(1, 'A')]))
        ..add(const NotesRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<NotesState>(
          (s) => s.status == NotesStatus.success && s.notes.length == 1,
        )),
      );
    });

    test('separates pinned from the rest', () async {
      final repo = FakeNotesRepository([
        buildNote(1, 'Plain'),
        buildNote(2, 'Important', pinned: true),
      ]);
      final bloc = NotesBloc(repo)..add(const NotesRequested());

      await bloc.stream.firstWhere((s) => s.status == NotesStatus.success);

      expect(bloc.state.pinned.single.title, 'Important');
      expect(bloc.state.others.single.title, 'Plain');
    });

    test('delete drops the note', () async {
      final repo = FakeNotesRepository([buildNote(1, 'A'), buildNote(2, 'B')]);
      final bloc = NotesBloc(repo)..add(const NotesRequested());

      await bloc.stream.firstWhere((s) => s.status == NotesStatus.success);
      bloc.add(const NoteDeleted(1));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<NotesState>((s) => s.notes.length == 1)),
      );
    });

    test('select all then delete clears the selected notes', () async {
      final repo = FakeNotesRepository([
        buildNote(1, 'A'),
        buildNote(2, 'B'),
        buildNote(3, 'C'),
      ]);
      final bloc = NotesBloc(repo)..add(const NotesRequested());
      await bloc.stream.firstWhere((s) => s.status == NotesStatus.success);

      bloc.add(const NoteSelectionToggled(1));
      bloc.add(const SelectAllToggled());
      await bloc.stream.firstWhere((s) => s.allSelected);
      expect(bloc.state.selectedIds, {1, 2, 3});

      bloc.add(const SelectedNotesDeleted());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<NotesState>(
          (s) => s.notes.isEmpty && s.selectedIds.isEmpty,
        )),
      );
    });

    test('toggling the last selected note leaves selection mode', () async {
      final repo = FakeNotesRepository([buildNote(1, 'A')]);
      final bloc = NotesBloc(repo)..add(const NotesRequested());
      await bloc.stream.firstWhere((s) => s.status == NotesStatus.success);

      bloc.add(const NoteSelectionToggled(1));
      await bloc.stream.firstWhere((s) => s.isSelecting);

      bloc.add(const NoteSelectionToggled(1));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<NotesState>((s) => !s.isSelecting)),
      );
    });
  });

  group('SearchCubit', () {
    test('starts empty and records searches most-recent-first', () async {
      final cubit = SearchCubit(FakeSearchRepository());
      await cubit.load();
      expect(cubit.state, isEmpty);

      await cubit.record('groceries');
      await cubit.record('roadmap');
      expect(cubit.state, ['roadmap', 'groceries']);
    });

    test('re-recording a term moves it up without duplicating', () async {
      final cubit = SearchCubit(FakeSearchRepository());
      await cubit.record('books');
      await cubit.record('roadmap');
      await cubit.record('books');
      expect(cubit.state, ['books', 'roadmap']);
    });

    test('remove drops a recent search', () async {
      final cubit = SearchCubit(FakeSearchRepository());
      await cubit.record('groceries');
      await cubit.record('roadmap');

      await cubit.remove('groceries');
      expect(cubit.state, ['roadmap']);
    });
  });
}
