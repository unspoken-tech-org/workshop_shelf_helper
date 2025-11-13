import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'migration.dart';

class MigrationV1 implements Migration {
  @override
  int get version => 1;

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_normalized TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE components (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        model TEXT NOT NULL,
        model_normalized TEXT,
        quantity INTEGER NOT NULL DEFAULT 0,
        location TEXT NOT NULL,
        location_normalized TEXT,
        polarity TEXT,
        package TEXT,
        unit_cost REAL NOT NULL DEFAULT 0.0,
        notes TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }
}
