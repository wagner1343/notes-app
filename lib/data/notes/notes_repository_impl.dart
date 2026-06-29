import 'package:injectable/injectable.dart';
import 'package:notes/core/models/note.dart';
import 'package:sqflite/sqflite.dart';

import 'package:notes/data/database/app_database.dart';
import 'package:notes/data/notes/notes_repository.dart';

@LazySingleton(as: NotesRepository)
class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._appDatabase);

  final AppDatabase _appDatabase;

  static const _table = 'notes';

  Database get _db => _appDatabase.db;

  @override
  Future<List<Note>> fetchNotes() async {
    final rows = await _db.query(
      _table,
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  @override
  Future<Note> upsert(Note note) async {
    if (note.id == null) {
      final id = await _db.insert(_table, note.toMap()..remove('id'));
      return note.copyWith(id: id);
    }

    await _db.update(
      _table,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    return note;
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(', ');
    await _db.delete(_table, where: 'id IN ($placeholders)', whereArgs: ids);
  }
}
