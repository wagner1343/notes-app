import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import 'package:notes/data/database/app_database.dart';
import 'package:notes/data/search/search_repository.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._appDatabase);

  final AppDatabase _appDatabase;

  static const _table = 'recent_searches';
  static const _limit = 8;

  Database get _db => _appDatabase.db;

  @override
  Future<List<String>> recentSearches() async {
    final rows = await _db.query(
      _table,
      columns: ['query'],
      orderBy: 'searched_at DESC',
      limit: _limit,
    );
    return rows.map((r) => r['query'] as String).toList();
  }

  @override
  Future<void> record(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    await _db.insert(
      _table,
      {'query': q, 'searched_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> remove(String query) async {
    await _db.delete(_table, where: 'query = ?', whereArgs: [query]);
  }
}
