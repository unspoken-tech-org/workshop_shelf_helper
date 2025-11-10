import 'package:flutter/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_seeder.dart';
import 'category_seeder.dart';
import 'component_seeder.dart';

class SeederRunner {
  List<DatabaseSeeder> get seeders => [CategorySeeder(), ComponentSeeder()];

  Future<void> seedAll(Database db) async {
    debugPrint('🌱 Starting database seed...');

    for (final seeder in seeders) {
      await seeder.seed(db);
    }

    debugPrint('✅ Seed completed successfully!');
  }

  Future<void> seedSpecific(Database db, String seederName) async {
    final seeder = seeders.firstWhere(
      (s) => s.name == seederName,
      orElse: () => throw Exception('Seeder "$seederName" not found'),
    );

    debugPrint('🌱 Running seeder: ${seeder.name}');
    await seeder.seed(db);
    debugPrint('✅ Seeder completed!');
  }

  Future<void> resetAndSeed(Database db) async {
    debugPrint('🗑️  Cleaning database...');

    await db.delete('components');
    await db.delete('categories');

    debugPrint('✓ Database cleaned');

    await _recreateInitialData(db);

    await seedAll(db);
  }

  Future<void> _recreateInitialData(Database db) async {
    final initialCategories = [
      {'name': 'Transistores', 'description': 'Transistores diversos'},
      {'name': 'Resistores', 'description': 'Resistores de diversos valores'},
      {'name': 'Capacitores', 'description': 'Capacitores eletrolíticos e cerâmicos'},
      {'name': 'Diodos', 'description': 'Diodos retificadores e LEDs'},
      {'name': 'Circuitos Integrados', 'description': 'CIs diversos'},
    ];

    for (final category in initialCategories) {
      await db.insert('categories', category);
    }
  }
}
