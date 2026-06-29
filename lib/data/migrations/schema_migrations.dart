import 'package:sqflite/sqflite.dart';

import 'package:notes/data/migrations/migration.dart';

final List<Migration> migrations = [
  _CreateNotesTable(),
  _CreateRecentSearchesTable(),
];

int get latestSchemaVersion =>
    migrations.fold(0, (max, m) => m.version > max ? m.version : max);

Future<void> applyMigrations(Database db,
    {required int from, required int to}) async {
  final pending = migrations
      .where((m) => m.version > from && m.version <= to)
      .toList()
    ..sort((a, b) => a.version.compareTo(b.version));

  for (final migration in pending) {
    await migration.up(db);
  }
}

class _CreateNotesTable implements Migration {
  @override
  int get version => 1;

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}

class _CreateRecentSearchesTable implements Migration {
  @override
  int get version => 2;

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE recent_searches (
        query TEXT PRIMARY KEY COLLATE NOCASE,
        searched_at INTEGER NOT NULL
      )
    ''');
  }
}
