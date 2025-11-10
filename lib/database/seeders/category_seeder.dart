import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_seeder.dart';

class CategorySeeder implements DatabaseSeeder {
  @override
  String get name => 'CategorySeeder';

  @override
  Future<void> seed(Database db) async {
    debugPrint('  🌱 Populating additional categories...');

    final categories = [
      {'name': 'Indutores', 'description': 'Indutores e bobinas'},
      {'name': 'Conectores', 'description': 'Conectores diversos (USB, HDMI, etc)'},
      {'name': 'Ferramentas', 'description': 'Ferramentas e equipamentos'},
      {'name': 'Placas', 'description': 'Placas de desenvolvimento (Arduino, ESP32, etc)'},
      {'name': 'Sensores', 'description': 'Sensores diversos (temperatura, distância, etc)'},
    ];

    for (final category in categories) {
      await db.insert('categories', category);
    }

    debugPrint('  ✓ ${categories.length} categories added');
  }
}
