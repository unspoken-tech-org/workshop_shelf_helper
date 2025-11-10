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
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE components (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        model TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        location TEXT NOT NULL,
        polarity TEXT,
        package TEXT,
        unit_cost REAL NOT NULL DEFAULT 0.0,
        notes TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    await db.insert('categories', {'name': 'Transistores', 'description': 'Transistores diversos'});
    await db.insert('categories', {
      'name': 'Resistores',
      'description': 'Resistores de diversos valores',
    });
    await db.insert('categories', {
      'name': 'Capacitores',
      'description': 'Capacitores eletrolíticos e cerâmicos',
    });
    await db.insert('categories', {'name': 'Diodos', 'description': 'Diodos retificadores e LEDs'});
    await db.insert('categories', {'name': 'Circuitos Integrados', 'description': 'CIs diversos'});
  }
}
