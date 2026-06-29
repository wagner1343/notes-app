import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:notes/data/migrations/schema_migrations.dart';

class AppDatabase {
  AppDatabase(this.db);

  final Database db;

  static Future<AppDatabase> open() async {
    final path = p.join(await getDatabasesPath(), 'notes.db');
    final db = await openDatabase(
      path,
      version: latestSchemaVersion,
      onCreate: (db, version) => applyMigrations(db, from: 0, to: version),
      onUpgrade: (db, oldVersion, newVersion) =>
          applyMigrations(db, from: oldVersion, to: newVersion),
    );
    return AppDatabase(db);
  }
}
