
import 'package:notes/core/models/note.dart';

abstract class NotesRepository {
  Future<List<Note>> fetchNotes();

  Future<Note> upsert(Note note);

  Future<void> delete(int id);

  Future<void> deleteMany(List<int> ids);
}
