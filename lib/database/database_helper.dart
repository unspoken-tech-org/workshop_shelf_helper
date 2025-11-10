import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'interfaces/i_database.dart';
import 'migrations/migration_runner.dart';
import 'seeders/seeder_runner.dart';

class DatabaseHelper implements IDatabase {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _ffiInitialized = false;

  final MigrationRunner _migrationRunner = MigrationRunner();
  final SeederRunner _seederRunner = SeederRunner();

  DatabaseHelper._init();

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workshop_shelf_helper.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!_ffiInitialized && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _ffiInitialized = true;
    }

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: _migrationRunner.latestVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _migrationRunner.onCreate(db, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _migrationRunner.onUpgrade(db, oldVersion, newVersion);
  }

  Future<void> seedDatabase() async {
    final db = await database;
    await _seederRunner.seedAll(db);
  }

  Future<void> resetWithMockData() async {
    final db = await database;
    await _seederRunner.resetAndSeed(db);
  }

  @override
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
